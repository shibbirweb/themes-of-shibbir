<!-- Vue single file component: template, script, and scoped style in one file. -->
<template>
  <section class="palette" :class="{ 'palette--empty': !visible.length }">
    <h1>{{ title }}</h1>

    <input
      v-model.trim="query"
      type="search"
      placeholder="Filter colors"
      :disabled="loading"
      @keyup.enter="refresh"
    />

    <ul v-if="visible.length">
      <li v-for="entry in visible" :key="entry.color" @click="select(entry.color)">
        <span class="swatch" :style="{ backgroundColor: entry.color }"></span>
        <strong>{{ entry.label }}</strong>
        <code>{{ entry.color }}</code>
      </li>
    </ul>
    <p v-else>No matches for "{{ query }}".</p>

    <slot name="footer" :count="visible.length" />
  </section>
</template>

<script>
export default {
  name: 'PaletteGrid',

  props: {
    title: {
      type: String,
      default: 'Palette preview',
    },
    entries: {
      type: Array,
      required: true,
    },
  },

  data() {
    return {
      query: '',
      selected: null,
      loading: false,
    };
  },

  computed: {
    visible() {
      const needle = this.query.toLowerCase();
      return this.entries.filter((entry) => entry.label.toLowerCase().includes(needle));
    },
  },

  watch: {
    selected(next, previous) {
      if (next !== previous) {
        this.$emit('change', next);
      }
    },
  },

  mounted() {
    this.refresh();
  },

  methods: {
    select(color) {
      this.selected = color;
    },

    async refresh() {
      this.loading = true;
      try {
        const { data } = await this.$http.get('/api/palette');
        this.$emit('loaded', data);
      } catch (error) {
        console.error(error);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped lang="scss">
.palette {
  display: grid;
  gap: 12px;

  &--empty {
    opacity: 0.6;
  }

  .swatch {
    width: 16px;
    height: 16px;
    border-radius: 50%;
  }
}
</style>
