// Package palette is a Go sample: structs, interfaces, goroutines, generics.
package palette

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"regexp"
	"sort"
	"sync"
	"time"
)

const (
	DefaultHex = "#EEFFFF"
	MaxDepth   = 8
	timeout    = 5 * time.Second
)

var (
	hexPattern    = regexp.MustCompile(`^#(?:[0-9a-fA-F]{3}){1,2}$`)
	ErrInvalidHex = errors.New("palette: invalid hex value")
)

type TokenKind int

const (
	KindComment TokenKind = iota
	KindKeyword
	KindString
	KindNumber
)

func (k TokenKind) String() string {
	switch k {
	case KindComment:
		return "comment"
	case KindKeyword:
		return "keyword"
	case KindString:
		return "string"
	default:
		return "unknown"
	}
}

type Swatch struct {
	Label string   `json:"label"`
	Hex   string   `json:"hex"`
	Tags  []string `json:"tags,omitempty"`
}

type Describer interface {
	Describe() string
}

func (s Swatch) Describe() string {
	return fmt.Sprintf("%s => %s", s.Label, s.Hex)
}

type Registry struct {
	mu       sync.RWMutex
	name     string
	swatches map[string]Swatch
}

func NewRegistry(name string) *Registry {
	return &Registry{
		name:     name,
		swatches: make(map[string]Swatch),
	}
}

func (r *Registry) Add(s Swatch) error {
	if !hexPattern.MatchString(s.Hex) {
		return fmt.Errorf("%w: %q", ErrInvalidHex, s.Hex)
	}

	r.mu.Lock()
	defer r.mu.Unlock()
	r.swatches[s.Label] = s

	return nil
}

func (r *Registry) Labels() []string {
	r.mu.RLock()
	defer r.mu.RUnlock()

	labels := make([]string, 0, len(r.swatches))
	for label := range r.swatches {
		labels = append(labels, label)
	}
	sort.Strings(labels)

	return labels
}

func Map[T any, U any](in []T, fn func(T) U) []U {
	out := make([]U, 0, len(in))
	for _, item := range in {
		out = append(out, fn(item))
	}
	return out
}

func LoadAll(ctx context.Context, paths []string) ([]Swatch, error) {
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	var (
		wg      sync.WaitGroup
		mu      sync.Mutex
		results []Swatch
	)

	for _, path := range paths {
		wg.Add(1)

		go func(p string) {
			defer wg.Done()

			raw, err := os.ReadFile(p)
			if err != nil {
				return
			}

			var s Swatch
			if err := json.Unmarshal(raw, &s); err != nil {
				return
			}

			mu.Lock()
			results = append(results, s)
			mu.Unlock()
		}(path)
	}

	done := make(chan struct{})
	go func() {
		wg.Wait()
		close(done)
	}()

	select {
	case <-done:
		return results, nil
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}
