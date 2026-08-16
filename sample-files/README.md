# Sample files

Test fixtures for eyeballing the themes. Open these in the Extension Development
Host (`F5`), then check each file under **both** contributed themes: "Themes of
Shibbir: Dark Solid" and "Themes of Shibbir: Dark Shades". Switching themes with
the same file open, via `Cmd+K Cmd+T`, is the fastest side-by-side comparison
available.

The two themes are independent palettes, so a construct that reads well in one
can still be wrong in the other.

These files are excluded from the packaged `.vsix` by `.vscodeignore`. Nothing
here is wired into a build; they exist only to be looked at.

## Web and app code

| File | Covers |
| --- | --- |
| `javascript.js` | comments, classes, template literals, regex, escapes, numbers, destructuring |
| `typescript.ts` | types, interfaces, generics, enums, decorators, type assertions |
| `react-component.tsx` | JSX tags, attributes, embedded expressions, hooks |
| `vue-component.vue` | template directives, script block, scoped SCSS block |
| `svelte-component.svelte` | reactive declarations, stores, each/if/await blocks |
| `template.hbs` | Handlebars expressions, block helpers, partials |
| `index.html` | tags, attributes, entities, embedded `<style>` and `<script>` |

## Stylesheets

The theme names five CSS dialects explicitly in its property-name rule, so each
gets its own file. Property names should render `#B2CCD6` in all of them.

| File | Covers |
| --- | --- |
| `styles.css` | custom properties, selectors, at-rules, functions |
| `styles.scss` | variables, nesting, mixins, control directives, placeholders |
| `styles.sass` | indented syntax, no braces or semicolons |
| `styles.less` | `@` variables, guarded mixins, recursive loops |
| `styles.styl` | Stylus, no braces, colons optional |
| `styles.pcss` | PostCSS nesting, custom media, custom selectors |

## Backend languages

| File | Covers |
| --- | --- |
| `sample.php` | namespaces, `use` statements, inheritance separator, heredoc and nowdoc |
| `template.blade.php` | Blade directives, escaped and raw echoes, components, `@php` blocks |
| `sample.py` | docstrings, decorators, dataclasses, type hints, comprehensions |
| `sample.go` | structs, interfaces, goroutines, generics, struct tags |
| `sample.rs` | traits, generics, lifetimes, attribute macros, pattern matching |
| `Sample.java` | annotations, records, streams, switch expressions, text blocks |
| `Sample.cs` | records, LINQ, properties, async, pattern matching |
| `Sample.kt` | data and sealed classes, extensions, coroutines, string templates |
| `sample.swift` | protocols, extensions, optionals, enums with associated values |
| `sample.dart` | null safety, mixins, async streams, cascades |
| `sample.rb` | modules, blocks, symbols, interpolation, heredocs |
| `sample.ex` | pattern matching, pipes, structs, sigils, module attributes |
| `sample.c` | preprocessor directives, structs, pointers, format strings |
| `sample.cpp` | templates, namespaces, smart pointers, lambdas, raw strings |
| `sample.lua` | tables, metatables, closures, long bracket strings |
| `sample.pl` | sigils, regex, references, heredocs, POD blocks |
| `sample.R` | vectors, data frames, pipes, formulas |

## Data and config

| File | Covers |
| --- | --- |
| `nested.json` | key colors at every nesting depth, 0 through 8 |
| `sample.yaml` | anchors, aliases, block scalars, nested maps and sequences |
| `ci.yml` | GitHub Actions expression syntax, matrices, multi-line `run` |
| `sample.toml` | tables, arrays of tables, inline tables, typed values |
| `sample.ini` | sections, both comment styles, quoted and bare values |
| `sample.xml` | declaration, namespaces, CDATA, entities, processing instructions |
| `sample.graphql` | schema definitions, operations, fragments, directives |
| `sample.proto` | messages, enums, services, streaming RPCs, maps |
| `schema.prisma` | datasource, models, relations, attributes |
| `sample.sql` | DDL, DML, joins, CTEs, window functions |
| `sample.csv` | quoted fields, embedded commas and quotes |
| `env.example` | dotenv keys, quoting, interpolation, inline comments |

## Tooling and ops

| File | Covers |
| --- | --- |
| `Dockerfile` | multi-stage builds, `ARG`/`ENV`, mounts, heredoc `RUN` |
| `Makefile` | variables, pattern rules, conditionals, tab-indented recipes |
| `Jenkinsfile` | declarative pipeline in Groovy, closures, string interpolation |
| `main.tf` | Terraform providers, resources, locals, comprehensions |
| `nginx.conf` | directives, blocks, `$variables`, regex locations |
| `sample.sh` | expansions, conditionals, loops, heredocs, `getopts` |
| `sample.bat` | labels, delayed expansion, both comment styles |
| `sample.ps1` | cmdlets, param blocks, pipelines, comment-based help |
| `sample.http` | request blocks, headers, variables, JSON and multipart bodies |
| `sample.diff` | added, removed, and changed line colors |
| `markdown-showcase.md` | headings, emphasis, links, blockquotes, tables, fenced blocks |

## Things worth checking specifically

- **`nested.json`** is the one file that cannot be replaced by a real project
  file. Themes commonly color JSON keys per nesting depth using progressively
  longer selector chains, and the `level0_key` through `level8_key` ladder is the
  only way to check every level at once. Neither theme defines those rules yet.
- **`sample.php`** exercises the PHP-specific scopes the themes call out by name
  (`support.other.namespace.use.php`, `meta.use.php`,
  `punctuation.separator.inheritance.php`).
- **`markdown-showcase.md`** covers seven of the token rules on its own, more than
  any other single fixture.
- **`sample.diff`** is the fastest check for the `markup.inserted`,
  `markup.deleted`, and `markup.changed` rules, which are otherwise only visible
  in a live git diff.
- **`sample.csv`** doubles as the reference palette for both themes: one row per
  intended token rule, with the Dark Solid and Dark Shades hex side by side. The
  theme files are skeletons being built up over time, so treat this as the target
  rather than a description of what they currently contain. It covers TextMate
  `tokenColors` only; `semanticTokenColors` is a separate mechanism and is
  already fully defined in both theme files.
- **`typescript.ts`** is the fixture for semantic highlighting. TypeScript ships
  a semantic token provider, so classes, interfaces, enums, decorators, and
  `readonly` members there resolve through `semanticTokenColors` rather than
  through the TextMate rules. `Developer: Inspect Editor Tokens and Scopes` shows
  a "semantic token type" line when that is happening.
- **Italic rules** are comments, `variable.language` (`this`, `self`, `$this`),
  decorators, markdown italic, and markdown quotes, so confirm your font has a
  real italic face. `invalid.deprecated` is the only strikethrough rule.
- **`Makefile`** recipes must stay tab-indented. If your editor converts tabs to
  spaces on save, the file stops being a valid Makefile even though it still
  highlights correctly.

## Finding a scope

With any of these files focused, run `Developer: Inspect Editor Tokens and Scopes`
from the Command Palette and hover a token. The popup shows the scope stack and
which theme rule won, which is the fastest way to locate the rule to edit.

## Notes

- `sample.php` uses a PHP 8 `match` expression. Everything else in it parses
  under PHP 7.4.
- `env.example` contains placeholder values only. It is deliberately not named
  `.env`: the repo gitignores that name, and this machine blocks writing to it.
- There is intentionally no `.editorconfig` here. One would apply to these files
  in your editor and could silently convert the `Makefile` tabs to spaces.
