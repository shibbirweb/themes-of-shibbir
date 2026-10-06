# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A themes-only VS Code extension. There is no source code, no build step, no dependencies, and no tests. `package.json` is a pure manifest whose `contributes.themes` entries point at the artifacts that matter: the four JSON files under `themes/`.

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
# git grep -I lists text files only, so icon.png is skipped, and --untracked
# includes new files not yet added. CI runs the same check.
git grep -I -z --name-only --untracked -e '' | xargs -0 perl -CSD -ne 'print "$ARGV:$.\n" if /[\x{2014}\x{2013}]/; close ARGV if eof'
```

## Commands

There is no build step. The only dependencies are the packaging tools (`@vscode/vsce`, `ovsx`); `pnpm install` fetches them. `vsce` 3 needs Node 20 or newer.

- **Dev loop:** press `F5` to launch an Extension Development Host (the `Extension` config in `.vscode/launch.json`, `type: extensionHost`). Edits to the theme JSON apply live in that window; no reload needed.
- **Activate a theme** in the host window: `Cmd+K Cmd+T`, then any "Themes of Shibbir: ..." entry. Switch between them in that same picker to compare.
- **Find the right scope before adding a token rule:** Command Palette → `Developer: Inspect Editor Tokens and Scopes`.
- **Validate the themes:** `pnpm validate` (runs `scripts/validate-themes.mjs`, then `scripts/version.mjs check`). It checks that every contributed theme parses, that `name` matches its label and `type` matches `uiTheme`, that every color is valid hex and every `fontStyle` is valid, and that each sibling pair in its `PAIRS` list is structurally parallel. Add a new theme pair to `PAIRS`. The version check confirms the changelog has a dated section for the `package.json` version and the README's install example names it.
- **Package a `.vsix`:** `pnpm package`. The `.vsix` is gitignored. Anything dev-only that should stay out of it goes in `.vscodeignore`.
- **CI:** `.github/workflows/ci.yml` runs on every pull request and every push to `main`: it validates the themes and the version, runs the dash check below, packages the `.vsix`, fails if the package holds anything besides `package.json`, `README.md`, `CHANGELOG.md`, `LICENSE`, `icon.png`, and `themes/*.json`, and uploads the `.vsix` as a build artifact. `publish.yml` runs the same checks before publishing.
- **Install locally without packaging:** copy the folder into `~/.vscode/extensions` and restart VS Code.

## Releasing

Never edit the version by hand. Releases go through two workflows:

1. **Record changes as they land.** Every pull request that changes what people install adds a line under `## [Unreleased]` in `CHANGELOG.md`, in the Keep a Changelog subsections (`### Added`, `### Changed`, `### Fixed`). Only release notes go there: the release workflow moves that whole section into the release, word for word, and refuses to run while it is empty.
2. **Start the release:** Actions, "Release", Run workflow, on `main`. Pick a level: `auto` reads the conventional commits since the last tag (any `feat` is minor; otherwise `fix`, `perf`, `refactor` or `style` is patch; a `!` after the type is major; docs, chore, ci and test alone call for none, so `auto` refuses). Tick "dry run" to preview. It runs `node scripts/version.mjs bump`, which sets `package.json`, dates the changelog section and its compare links, and updates the README's `.vsix` example. Then it opens a `chore: release x.y.z` pull request from `release/vx.y.z` with the notes in its description, and dispatches CI on it.
3. **Merge that pull request.** That is the decision to release. When CI passes on `main`, `publish.yml` sees a version with no tag, publishes to the VS Code Marketplace and Open VSX, and then creates the `vx.y.z` tag and GitHub release with the changelog section as notes and the `.vsix` attached.

The release workflow refuses to start unless CI passed on `main`'s tip, the current version is already tagged, and no other release pull request is open. It needs the repository setting Settings, Actions, General, "Allow GitHub Actions to create and approve pull requests". Publishing needs the `VSCE_PAT` secret; `OVSX_PAT` is optional and skips Open VSX when unset.

If a publish fails, use "Re-run failed jobs" on it, or run Publish Extension by hand from `main`. The tag is created last and both marketplace publishes skip a version they already have, so retrying is safe.

To inspect locally: `node scripts/version.mjs show`, `level` (what `auto` would pick), and `notes [x.y.z]`.

## The themes

The extension contributes four themes, registered in `contributes.themes` in `package.json`. Adding another means adding an entry there plus a file under `themes/`; nothing else wires them up. A light theme takes `"uiTheme": "vs"` in `package.json` and `"type": "light"` in its file.

| Label in the picker | File | Character |
| --- | --- | --- |
| Themes of Shibbir: Dark Solid | `themes/dark-solid-color-theme.json` | one flat surface color everywhere, vivid saturated syntax |
| Themes of Shibbir: Dark Shades | `themes/dark-shades-color-theme.json` | layered surfaces at five depths, muted desaturated syntax |
| Themes of Shibbir: Islands Dark | `themes/islands-dark-color-theme.json` | island surfaces on a lighter frame, warm calm syntax |
| Themes of Shibbir: Islands Light | `themes/islands-light-color-theme.json` | white islands on a gray frame, crisp dark syntax |

Every theme label carries the `Themes of Shibbir: ` prefix so all of them group together in the Color Theme picker, which sorts alphabetically. Keep that prefix on any theme added later, and keep the `name` inside each JSON file identical to its `label` in `package.json`.

They are **independent palettes**, not variants of each other. A color change in one does not imply the same change in another. That holds for the Islands pair too: Islands Dark and Islands Light are two separate palettes, not one palette inverted.

Each file has four parts: `colors` for workbench chrome, `tokenColors` for TextMate scope rules, `semanticTokenColors` for language-server tokens, and `"type"` plus `"semanticHighlighting": true` at the top.

### Why the engine floor is 1.12, and why it stays there

`engines.vscode` is `^1.12.0`: the release that introduced workbench `colors`, and therefore the oldest VS Code on which both halves of these files do something. The range has no upper bound, so current and future releases are covered without ever bumping it.

**Do not raise it just because a newer feature gets used.** Themes are data, not code. VS Code applies the properties and color keys it recognises and silently ignores the rest, so newer constructs degrade instead of failing:

- `semanticHighlighting` and `semanticTokenColors` need 1.43. Below that they are skipped and syntax coloring falls back to `tokenColors`.
- Recent color keys (chat, inline chat, command center, source control graph, sticky scroll, inlay hints) are dropped by builds that predate them, leaving VS Code's own defaults for that chrome.

Neither case errors, warns, or blocks installation. The precedent is Dracula, a themes-only extension that declares `^1.13.0` while shipping `inlineChat.*` keys from 2023.

The floor was briefly raised to `^1.43.0` and deliberately reverted. Maximum installability, including on forks and pinned corporate installs that report older base versions, is worth more here than declaring an exact feature floor. Raise it only if a theme ever depends on something that genuinely breaks when absent.

### Current state: two skeletons, two complete themes

**Dark Solid and Dark Shades are skeletons.** Each carries `editor.background`, `editor.foreground`, `sideBar.background`, a single `comment` token rule, and a full `semanticTokenColors` block. Shibbir extends them incrementally, so **do not bulk-generate rules into these two files unless asked**. Add what the current task needs and nothing more. Their `semanticTokenColors` block is the one exception to that minimalism: it was filled in on request, and it draws every value from the reference palettes below.

**Islands Dark and Islands Light are complete.** They were built on request against the official VS Code theme color reference (`api/references/theme-color.md` in `microsoft/vscode-docs`): every key in it is set except the seven listed under "Islands themes: how the colors were mapped" below. They also carry a full `tokenColors` rule set (60 rules) and an extended `semanticTokenColors` block. When VS Code adds new color keys, add them to both Islands files in the same position the reference lists them.

Conventions to preserve:

- **Keep each pair structurally parallel.** Dark Solid and Dark Shades mirror each other; Islands Dark and Islands Light mirror each other. Within a pair: same workbench keys, same token rule names and scopes, same `settings` keys, in the same order. Only the values differ. If you add a rule to one file of a pair, add the matching rule to the other, or the files stop being diffable against each other. (Islands Dark sets the comment `fontStyle` to `""` rather than dropping the key, because that theme deliberately keeps comments upright.)
- **Keep each theme's identity in its surfaces.** Dark Solid uses one flat value for every surface key, which is why `sideBar.background` currently equals `editor.background`. Dark Shades layers its surfaces, which is why its two differ. The Islands themes use two surface values: the island color for content (editor, sidebar, panel, terminal, tabs) and a frame color around them (title bar, activity bar, status bar, and the borders between islands). Any surface key added later has to respect that: identical values in solid, stepped values in shades, island-or-frame in the Islands themes.

### Islands themes: how the colors were mapped

- **Roles, not one-offs.** Every value plays a named role from the palette tables below (island, frame, accent, selection, syntax role, and so on). Reuse the hex for that role rather than introducing a new one.
- **Terminal ANSI colors** have their own set of values per theme; reuse them as they are.
- **Transparency.** VS Code requires several editor decorations (word highlight, find matches, diff, merge, inactive selection, folding, bracket match) to be non-opaque so they do not hide each other. Each such key holds the most transparent color that composites to the intended opaque color over the editor background. To change one, pick the opaque color you want to see and solve for the transparent equivalent the same way, rather than hand-tuning the alpha.

Keys deliberately left unset, so VS Code keeps its own behavior:

| Key | Why |
| --- | --- |
| `contrastBorder`, `contrastActiveBorder` | high contrast only; setting them outlines every part of the workbench |
| `editor.selectionForeground` | high contrast only |
| `editor.findMatchForeground`, `editor.findMatchHighlightForeground` | would replace syntax colors inside search matches |
| `editorBracketMatch.foreground` | would replace bracket colors; the theme only adds a background |
| `terminal.selectionForeground` | would replace ANSI colors inside a terminal selection |

Two notes on syntax: bracket pair colorization uses three hues from the syntax palette (tag, field, function); and function calls take the declaration color in TextMate rules, since most grammars do not separate calls from declarations.

The tables below are the **reference palettes**. For Dark Solid and Dark Shades they are not an inventory of what the files contain today. They record the intended role for each hex so colors stay consistent as rules are added. Reuse a hex from the relevant table rather than introducing a new one.

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

### Islands Dark palette

Surfaces: `#191A1C` is the island (editor, sidebar, panel, terminal, editor tabs) and `#26282C` is the frame around the islands (title bar, activity bar, status bar) and also the island border. Editor details: caret `#CED0D6`, current line `#1F2024`, line numbers `#4B5059` (active `#A1A3AB`), indent guides `#323438`. Gutter diff: added `#549159`, modified `#375FAD`, deleted `#868A91`.

| Color | Role |
| --- | --- |
| `#BCBEC4` | default foreground, identifiers, classes and types, parameters, punctuation, operators |
| `#7A7E85` | comments (not italic) |
| `#5F826B` | doc comments (italic) |
| `#CF8E6D` | keywords, storage, string escapes, YAML and TOML keys, CSS tag selectors and at-rules |
| `#6AAB73` | strings |
| `#2AACB8` | numbers |
| `#56A8F5` | functions, methods |
| `#C77DBB` | fields, properties, JSON keys, CSS property names, Markdown headings, constants and enum members (italic when constant or static) |
| `#16BAAC` | type parameters |
| `#B3AE60` | annotations, decorators, macros, preprocessor |
| `#D5B778` | HTML and XML tag names and tag punctuation |
| `#2FBAA3` | custom tags and components |
| `#42C3D4` | regex |
| `#F75464` | invalid |

### Islands Light palette

Surfaces: `#FFFFFF` is the island (editor, sidebar, panel, terminal, editor tabs) and `#E9EAEE` is the frame (title bar, activity bar, status bar) and island border. Editor details: current line `#F5F8FE`, selection `#A6D2FF`, line numbers `#AEB3C2` (active `#767A8A`), indent guides `#EBECF0`. Gutter diff: added `#7FC784`, modified `#88ADF7`, deleted `#767A8A`.

| Color | Role |
| --- | --- |
| `#080808` | default foreground, identifiers, classes and types, parameters |
| `#8C8C8C` | comments and doc comments (italic) |
| `#0033B3` | keywords, storage, HTML and XML tag names, YAML and TOML keys, CSS tag selectors |
| `#0037A6` | string escapes |
| `#067D17` | strings |
| `#1750EB` | numbers |
| `#00627A` | functions, methods |
| `#871094` | fields, properties, JSON keys, CSS property names, Markdown headings, constants and enum members (italic when constant or static) |
| `#007E8A` | type parameters |
| `#9E880D` | annotations, decorators, macros |
| `#174AD4` | HTML and XML attributes |
| `#008077` | custom tags and components |

### JSON key depth

Neither theme colors JSON keys by nesting depth yet. If that gets added, the selectors are progressively longer `meta.structure.dictionary.json` and `meta.structure.dictionary.value.json` chains, one per level, and each is an ancestor match: keys deeper than the last defined level fall through to it. `sample-files/nested.json` runs to level 8 so any such chain can be checked at a glance.

## Testing a change

`sample-files/` holds fixtures for visually checking the theme across roughly fifty languages and formats: web code, six CSS dialects, seventeen backend languages, data and config formats, and tooling files. Open them in the Extension Development Host after pressing `F5`. `sample-files/README.md` maps each file to the scopes it covers.

Check every change in **every** theme it touches, and when a rule is added to all four files, look at all four. The fixtures are shared, so switching themes with the same file open is the fastest side-by-side comparison you get.

Three fixtures reach rules nothing else does:

- `nested.json` verifies JSON key-depth chains, if and when those rules are added.
- `sample.php` is the only fixture covering the PHP-specific scopes.
- `sample.diff` is the only fixture covering `markup.inserted`, `markup.deleted`, and `markup.changed`.

The Islands themes name six CSS dialects in their property-name and selector rules (`css`, `sass`, `scss`, `less`, `stylus`, `postcss`), which is why there are six stylesheet fixtures rather than one. Any CSS rule added to Dark Solid or Dark Shades should name the same six.

The folder is excluded from the packaged `.vsix`.

## Metadata files

`README.md`, `CHANGELOG.md`, and `vsc-extension-quickstart.md` are still generator boilerplate. `.vscodeignore` keeps `.vscode/**`, `.gitignore`, and the quickstart out of the packaged `.vsix`; add new dev-only files there.
