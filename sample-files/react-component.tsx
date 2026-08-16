// JSX sample: component tags, attributes, embedded expressions.

import React, { useCallback, useEffect, useMemo, useState } from 'react';

interface SwatchProps {
  label: string;
  color: string;
  active?: boolean;
  onSelect: (color: string) => void;
}

const PALETTE: ReadonlyArray<{ label: string; color: string }> = [
  { label: 'Background', color: '#263238' },
  { label: 'Foreground', color: '#EEFFFF' },
  { label: 'Keyword', color: '#C792EA' },
  { label: 'String', color: '#C3E88D' },
];

export function Swatch({ label, color, active = false, onSelect }: SwatchProps): JSX.Element {
  const handleClick = useCallback(() => {
    onSelect(color);
  }, [color, onSelect]);

  return (
    <button
      type="button"
      className={`swatch ${active ? 'swatch--active' : ''}`}
      style={{ backgroundColor: color }}
      aria-pressed={active}
      onClick={handleClick}
    >
      <span className="swatch__label">{label}</span>
      <code>{color}</code>
    </button>
  );
}

export default function PaletteGrid(): JSX.Element {
  const [selected, setSelected] = useState<string | null>(null);
  const [query, setQuery] = useState('');

  const visible = useMemo(
    () => PALETTE.filter((entry) => entry.label.toLowerCase().includes(query.toLowerCase())),
    [query],
  );

  useEffect(() => {
    if (selected !== null) {
      document.title = `Selected ${selected}`;
    }

    return () => {
      document.title = 'Palette';
    };
  }, [selected]);

  return (
    <section className="palette">
      <h1>Palette preview</h1>
      <input
        type="search"
        value={query}
        placeholder="Filter colors"
        onChange={(event) => setQuery(event.target.value)}
      />

      {visible.length === 0 ? (
        <p>No matches for &quot;{query}&quot;.</p>
      ) : (
        <div className="palette__grid">
          {visible.map((entry) => (
            <Swatch
              key={entry.color}
              label={entry.label}
              color={entry.color}
              active={entry.color === selected}
              onSelect={setSelected}
            />
          ))}
        </div>
      )}

      {/* JSX comment */}
      <footer>{visible.length} of {PALETTE.length} shown</footer>
    </section>
  );
}
