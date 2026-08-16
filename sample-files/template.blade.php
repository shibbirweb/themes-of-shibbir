{{-- Laravel Blade sample: directives, echoes, components, and inline PHP. --}}

@extends('layouts.app')

@section('title', 'Palette preview')

@php
    $accent = '#82AAFF';
    $total = count($swatches ?? []);
@endphp

@push('styles')
    <link rel="stylesheet" href="{{ asset('css/palette.css') }}">
@endpush

@section('content')
    <div class="container" id="palette-{{ $theme->id }}">
        <h1>{{ $theme->name }}</h1>

        {{-- Escaped echo, then raw echo. --}}
        <p>{{ $theme->description }}</p>
        <p>{!! $theme->html_description !!}</p>

        @if ($total > 0)
            <span class="badge">{{ $total }} {{ Str::plural('swatch', $total) }}</span>
        @elseif ($theme->is_draft)
            <span class="badge badge--muted">Draft</span>
        @else
            <span class="badge badge--empty">No swatches yet</span>
        @endif

        @unless (auth()->guest())
            <a href="{{ route('themes.edit', ['themeId' => $theme->id]) }}" class="btn">Edit</a>
        @endunless

        <ul class="palette">
            @forelse ($swatches as $index => $swatch)
                <li class="palette__item @if ($loop->first) is-first @endif">
                    <span class="swatch" style="background-color: {{ $swatch->hex }}"></span>
                    <strong>{{ $swatch->label }}</strong>
                    <code>{{ strtoupper($swatch->hex) }}</code>

                    @isset($swatch->font_style)
                        <em>{{ $swatch->font_style }}</em>
                    @endisset
                </li>
            @empty
                <li class="palette__item palette__item--empty">Nothing to show.</li>
            @endforelse
        </ul>

        @foreach ($tokenGroups as $group => $tokens)
            <section>
                <h2>{{ ucfirst($group) }}</h2>

                @switch($group)
                    @case('markup')
                        <p>Markdown and markup scopes.</p>
                        @break
                    @case('source')
                        <p>Language scopes.</p>
                        @break
                    @default
                        <p>Other scopes.</p>
                @endswitch

                <x-token-list :tokens="$tokens" :accent="$accent" />
            </section>
        @endforeach

        @include('partials.footer', ['count' => $total])

        @auth
            <form method="POST" action="{{ route('themes.publish', $theme) }}">
                @csrf
                @method('PATCH')
                <button type="submit">Publish</button>
            </form>
        @endauth
    </div>
@endsection

@section('scripts')
    <script>
        window.THEME = @json($theme->only(['id', 'name']));
    </script>
@endsection
