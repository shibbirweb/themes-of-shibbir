// Single line comment: should render italic in #546E7A.

/**
 * Block comment with a @tag and a URL: https://example.com
 * Exercises: comment, punctuation.definition.comment.
 */

import { readFile, writeFile } from 'node:fs/promises';
import defaultExport, * as namespace from './module.js';

const PI = 3.14159;
const HEX = 0xff;
const BIG = 9_007_199_254_740_991n;
const SCIENTIFIC = 1.42e-9;
const NOTHING = null;
const MISSING = undefined;
const YES = true;

// Strings, escapes, and template substitution.
const single = 'single quoted';
const double = "double \"escaped\" quoted";
const escapes = 'tab:\t newline:\n unicode:é hex:\x41';
const templated = `total: ${PI * 2} and nested ${`inner ${HEX}`}`;

// Regular expressions.
const EMAIL = /^[\w.+-]+@[\w-]+\.[\w.]{2,}$/gi;
const SLUG = new RegExp('^[a-z0-9]+(?:-[a-z0-9]+)*$', 'u');

class ThemeRegistry extends EventTarget {
  #private = new Map();
  static VERSION = '1.0.0';

  constructor(options = {}) {
    super();
    this.options = { strict: false, ...options };
  }

  get size() {
    return this.#private.size;
  }

  set label(value) {
    this.#private.set('label', value);
  }

  static create(...args) {
    return new ThemeRegistry(...args);
  }

  async load(path) {
    try {
      const raw = await readFile(path, 'utf8');
      return JSON.parse(raw);
    } catch (error) {
      if (error.code === 'ENOENT') {
        return null;
      }
      throw error;
    } finally {
      this.dispatchEvent(new Event('loaded'));
    }
  }

  *entries() {
    yield* this.#private.entries();
  }
}

// Arrow functions, destructuring, default and rest parameters.
const format = ({ name, color = '#EEFFFF' }, ...rest) => `${name}: ${color}${rest.join('')}`;

// Object literal with shorthand, computed keys, and a method.
const palette = {
  background: '#263238',
  foreground: '#EEFFFF',
  [`accent${1}`]: '#82AAFF',
  PI,
  describe() {
    return Object.keys(this).length;
  },
};

// Control flow, operators, and ternaries.
function classify(value) {
  if (typeof value === 'number' && !Number.isNaN(value)) {
    return value > 0 ? 'positive' : 'non-positive';
  }

  switch (typeof value) {
    case 'string':
      return value.length > 0 ? 'text' : 'empty';
    case 'object':
      return value === null ? 'null' : 'object';
    default:
      return 'unknown';
  }
}

for (const [key, value] of Object.entries(palette)) {
  if (typeof value === 'string') {
    console.log(`${key} -> ${value}`);
  }
}

const filtered = Object.values(palette)
  .filter((value) => typeof value === 'string')
  .map((value) => value.toUpperCase())
  .sort();

export { ThemeRegistry, palette, classify, format, filtered, EMAIL, SLUG };
export default ThemeRegistry;
