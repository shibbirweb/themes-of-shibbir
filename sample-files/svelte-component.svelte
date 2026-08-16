<!-- Svelte sample: reactive declarations, stores, each and if blocks. -->
<script>
  import { createEventDispatcher, onDestroy, onMount } from 'svelte';
  import { writable } from 'svelte/store';

  export let title = 'Palette preview';
  export let entries = [];

  const dispatch = createEventDispatcher();
  const selected = writable(null);

  let query = '';
  let loading = false;

  $: needle = query.trim().toLowerCase();
  $: visible = entries.filter((entry) => entry.label.toLowerCase().includes(needle));
  $: if ($selected) {
    dispatch('change', { color: $selected });
  }

  function select(color) {
    selected.set(color);
  }

  async function refresh() {
    loading = true;

    try {
      const response = await fetch('/api/palette');
      entries = await response.json();
    } catch (error) {
      console.error(error);
    } finally {
      loading = false;
    }
  }

  onMount(refresh);
  onDestroy(() => selected.set(null));
</script>

<section class="palette" class:is-loading={loading}>
  <h1>{title}</h1>

  <input type="search" bind:value={query} placeholder="Filter colors" disabled={loading} />

  {#if loading}
    <p>Loading...</p>
  {:else if visible.length === 0}
    <p>No matches for "{query}".</p>
  {:else}
    <ul>
      {#each visible as entry, index (entry.color)}
        <li on:click={() => select(entry.color)}>
          <span class="swatch" style="background-color: {entry.color}"></span>
          <strong>{entry.label}</strong>
          <code>{entry.color}</code>
          <small>#{index + 1}</small>
        </li>
      {/each}
    </ul>
  {/if}

  {#await refresh() then _}
    <slot name="footer" count={visible.length} />
  {:catch error}
    <p class="error">{error.message}</p>
  {/await}
</section>

<style>
  .palette {
    display: grid;
    gap: 12px;
    color: #eeffff;
    background-color: #263238;
  }

  .palette.is-loading {
    opacity: 0.6;
  }

  .swatch {
    width: 16px;
    height: 16px;
    border-radius: 50%;
  }
</style>
