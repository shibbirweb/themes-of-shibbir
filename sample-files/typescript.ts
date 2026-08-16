// TypeScript sample: types, generics, decorators, enums.

type Hex = `#${string}`;
type Nullable<T> = T | null;
type Keys = keyof ThemeColors;

interface ThemeColors {
  readonly background: Hex;
  readonly foreground: Hex;
  accent?: Hex;
}

interface Loader<T> {
  load(path: string): Promise<Nullable<T>>;
}

enum TokenKind {
  Comment = 'comment',
  Keyword = 'keyword',
  StringLiteral = 'string',
  Number = 'constant.numeric',
}

const enum Priority {
  Low = 0,
  High = 100,
}

abstract class BaseTheme implements Loader<ThemeColors> {
  protected abstract readonly name: string;
  private cache = new Map<string, ThemeColors>();

  public constructor(public readonly uiTheme: 'vs-dark' | 'vs' = 'vs-dark') {}

  public abstract describe(): string;

  public async load(path: string): Promise<Nullable<ThemeColors>> {
    const cached = this.cache.get(path);
    if (cached !== undefined) {
      return cached;
    }
    return null;
  }
}

function logged(target: unknown, key: string, descriptor: PropertyDescriptor): PropertyDescriptor {
  const original = descriptor.value as (...args: unknown[]) => unknown;
  descriptor.value = function wrapped(...args: unknown[]): unknown {
    return original.apply(this, args);
  };
  return descriptor;
}

class MaterialOcean extends BaseTheme {
  protected readonly name = 'Themes of Shibbir';

  @logged
  public describe(): string {
    return `${this.name} (${this.uiTheme})`;
  }
}

function pick<T extends object, K extends keyof T>(source: T, keys: readonly K[]): Pick<T, K> {
  return keys.reduce((accumulator, key) => {
    accumulator[key] = source[key];
    return accumulator;
  }, {} as Pick<T, K>);
}

function isHex(value: unknown): value is Hex {
  return typeof value === 'string' && /^#[0-9a-f]{3,8}$/i.test(value);
}

const colors: ThemeColors = {
  background: '#263238',
  foreground: '#EEFFFF',
  accent: '#82AAFF',
};

const picked = pick(colors, ['background', 'foreground'] as const);
const asserted = colors.accent as Hex;
const optional = colors.accent?.toUpperCase() ?? '#FFFFFF';

export { BaseTheme, MaterialOcean, TokenKind, Priority, pick, isHex, colors, picked, asserted, optional };
export type { ThemeColors, Hex, Nullable, Keys, Loader };
