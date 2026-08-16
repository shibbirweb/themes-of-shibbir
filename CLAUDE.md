# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A single-theme VS Code color theme extension. There is no source code, no build step, no dependencies, and no tests. `package.json` is a pure manifest whose `contributes.themes` entry points at the one artifact that matters: `themes/Themes of Shibbir-color-theme.json`.

## Git

**Never run `git commit` until Shibbir explicitly asks for it.** Make the edits, report what changed, and stop there. Leave the changes staged or unstaged in the working tree and wait. "The change is finished", "the task is done", or "it passes verification" are not permission to commit. Only a direct instruction such as "commit", "commit this", or "now commit" is. The same applies to `git push`, `git commit --amend`, and any other history-writing command.

Commit identity is set repo-locally and must stay that way: `Md. Shibbir Ahmed <shibbirweb@gmail.com>`. This is a personal repo, so it deliberately differs from the global/work identity.

Never add a `Co-Authored-By: Claude ...` trailer (or any other AI co-author attribution) to commit messages here. Commits are authored by Md. Shibbir Ahmed only.

## Writing style

**Never use the em-dash character (U+2014) anywhere**: not in code, comments, sample files, documentation, commit messages, or PR text. This is not a formatting preference, it is a hard rule. Use a colon, semicolon, comma, or parentheses instead, or split the sentence in two. The same goes for the en-dash (U+2013) in prose; a plain hyphen is fine in compound words and ranges.

Verify before handing work back:

```sh
# Must return nothing. Uses perl codepoint escapes so the command does
# not itself contain the characters it searches for, which would make it
# match its own source. macOS grep has no -P, so grep cannot do this.
git ls-files -z | xargs -0 perl -CSD -ne 'print "$ARGV:$.\n" if /[\x{2014}\x{2013}]/'
```

## Commands

There are no npm scripts and no `node_modules`. Everything is either an editor action or a one-off `npx`.

- **Dev loop:** press `F5` to launch an Extension Development Host (the `Extension` config in `.vscode/launch.json`, `type: extensionHost`). Edits to the theme JSON apply live in that window; no reload needed.
- **Activate a theme** in the host window: `Cmd+K Cmd+T`, then "Themes of Shibbir: Dark Solid" or "Themes of Shibbir: Dark Shades". Switch between them in that same picker to compare.
- **Find the right scope before adding a token rule:** Command Palette → `Developer: Inspect Editor Tokens and Scopes`.
- **Package a `.vsix`:** `npx @vscode/vsce package` (vsce is not a devDependency). The `.vsix` is gitignored.
- **Install locally without packaging:** copy the folder into `~/.vscode/extensions` and restart VS Code.

## The two themes

The extension contributes two themes, registered in `contributes.themes` in `package.json`. Adding a third means adding an entry there plus a file under `themes/`; nothing else wires them up.

| Label in the picker | File | Character |
| --- | --- | --- |
| Themes of Shibbir: Dark Solid | `themes/dark-solid-color-theme.json` | one flat surface color everywhere, vivid saturated syntax |
| Themes of Shibbir: Dark Shades | `themes/dark-shades-color-theme.json` | layered surfaces at five depths, muted desaturated syntax |

Every theme label carries the `Themes of Shibbir: ` prefix so all of them group together in the Color Theme picker, which sorts alphabetically. Keep that prefix on any theme added later, and keep the `name` inside each JSON file identical to its `label` in `package.json`.

They are **independent palettes**, not variants of each other. A color change in one does not imply the same change in the other.

Each file has four parts: `colors` for workbench chrome, `tokenColors` for TextMate scope rules, `semanticTokenColors` for language-server tokens, and `"type": "dark"` plus `"semanticHighlighting": true` at the top.

### Why the engine floor is 1.12, and why it stays there

`engines.vscode` is `^1.12.0`: the release that introduced workbench `colors`, and therefore the oldest VS Code on which both halves of these files do something. The range has no upper bound, so current and future releases are covered without ever bumping it.

**Do not raise it just because a newer feature gets used.** Themes are data, not code. VS Code applies the properties and color keys it recognises and silently ignores the rest, so newer constructs degrade instead of failing:

- `semanticHighlighting` and `semanticTokenColors` need 1.43. Below that they are skipped and syntax coloring falls back to `tokenColors`.
- Recent color keys (chat, inline chat, command center, source control graph, sticky scroll, inlay hints) are dropped by builds that predate them, leaving VS Code's own defaults for that chrome.

Neither case errors, warns, or blocks installation. The precedent is Dracula, a themes-only extension that declares `^1.13.0` while shipping `inlineChat.*` keys from 2023.

The floor was briefly raised to `^1.43.0` and deliberately reverted. Maximum installability, including on forks and pinned corporate installs that report older base versions, is worth more here than declaring an exact feature floor. Raise it only if a theme ever depends on something that genuinely breaks when absent.

### Current state: skeletons, built up over time

Both files are deliberately minimal right now. Each carries `editor.background`, `editor.foreground`, `sideBar.background`, a single `comment` token rule, and a full `semanticTokenColors` block. Shibbir extends them incrementally, so **do not bulk-generate rules into these files unless asked**. Add what the current task needs and nothing more.

The `semanticTokenColors` block is the one exception to that minimalism: it was filled in on request, and it draws every value from the reference palettes below.

Two conventions to preserve while they grow:

- **Keep the two files structurally parallel.** Same workbench keys, same token rule names, in the same order. Only the hex values differ. If you add a rule to one, add the matching rule to the other, or the files stop being diffable against each other.
- **Keep each theme's identity in its surfaces.** Dark Solid uses one flat value for every surface key, which is why `sideBar.background` currently equals `editor.background`. Dark Shades layers its surfaces, which is why its two differ. Any surface key added later has to respect that: identical values in solid, stepped values in shades.

The tables below are the **reference palettes**, not an inventory of what the files contain today. They record the intended role for each hex so colors stay consistent as rules are added. Reuse a hex from the relevant table rather than introducing a new one.

### Dark Solid palette

Surfaces are deliberately uniform. As surface keys get added (`activityBar`, `panel`, `statusBar`, `titleBar`, both tab states), they all take `#1E2227`, separated only by `#2C3238` borders. Introducing a second surface color defeats the point of the theme.

| Color | Role |
| --- | --- |
| `#D9E0E8` | default foreground |
| `#5C6773` | comments (italic), tag punctuation, quotes |
| `#C678DD` | keywords, storage, `variable.language` (italic) |
| `#56B6C2` | operators, punctuation, escapes, regex, links |
| `#61AFEF` | functions, decorators, CSS property names, headings |
| `#98C379` | strings, raw code, diff inserted |
| `#D19A66` | numbers, constants, parameters, attributes, bold |
| `#E5C07B` | classes, types, CSS classes, PHP namespaces, diff changed |
| `#E06C75` | variables, tags, diff deleted |
| `#FF5370` | invalid |

### Dark Shades palette

Surfaces step through five depths, darkest chrome to lightest editor: `#10151A` status bar, `#12171C` activity and title bar, `#151B21` panel and terminal, `#161C22` sidebar and widgets, `#1B222A` editor. Only the editor and sidebar steps exist in the file so far. That ordering is the theme's identity; place any new surface key at its correct depth.

| Color | Role |
| --- | --- |
| `#C3CBD5` | default foreground |
| `#556070` | comments (italic), tag punctuation, quotes |
| `#A98CC8` | keywords, storage, `variable.language` (italic) |
| `#6FA3A8` | operators, punctuation, escapes, regex, links |
| `#7BA7CC` | functions, decorators, CSS property names, headings |
| `#8FB98A` | strings, raw code, diff inserted |
| `#C39B72` | numbers, constants, parameters, attributes, bold |
| `#C9B285` | classes, types, CSS classes, PHP namespaces, diff changed |
| `#C08A8F` | variables, tags, diff deleted |
| `#C96A6A` | invalid |

### JSON key depth

Neither theme colors JSON keys by nesting depth yet. If that gets added, the selectors are progressively longer `meta.structure.dictionary.json` and `meta.structure.dictionary.value.json` chains, one per level, and each is an ancestor match: keys deeper than the last defined level fall through to it. `sample-files/nested.json` runs to level 8 so any such chain can be checked at a glance.

## Testing a change

`sample-files/` holds fixtures for visually checking the theme across roughly fifty languages and formats: web code, six CSS dialects, seventeen backend languages, data and config formats, and tooling files. Open them in the Extension Development Host after pressing `F5`. `sample-files/README.md` maps each file to the scopes it covers.

Check every change in **both** themes. The fixtures are shared, so switching themes with the same file open is the fastest side-by-side comparison you get.

Three fixtures reach rules nothing else does:

- `nested.json` verifies JSON key-depth chains, if and when those rules are added.
- `sample.php` is the only fixture covering the PHP-specific scopes.
- `sample.diff` is the only fixture covering `markup.inserted`, `markup.deleted`, and `markup.changed`.

Both themes name six CSS dialects in their property-name rule (`css`, `sass`, `scss`, `less`, `stylus`, `postcss`), which is why there are six stylesheet fixtures rather than one.

The folder is excluded from the packaged `.vsix`.

## Metadata files

`README.md`, `CHANGELOG.md`, and `vsc-extension-quickstart.md` are still generator boilerplate. `.vscodeignore` keeps `.vscode/**`, `.gitignore`, and the quickstart out of the packaged `.vsix`; add new dev-only files there.
