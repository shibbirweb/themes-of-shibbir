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
- **Activate the theme** in the host window: `Cmd+K Cmd+T` → "Themes of Shibbir".
- **Find the right scope before adding a token rule:** Command Palette → `Developer: Inspect Editor Tokens and Scopes`.
- **Package a `.vsix`:** `npx @vscode/vsce package` (vsce is not a devDependency). The `.vsix` is gitignored.
- **Install locally without packaging:** copy the folder into `~/.vscode/extensions` and restart VS Code.

The theme filename contains spaces, so quote it in shell commands. If it is ever renamed, `contributes.themes[0].path` in `package.json` must match the new name exactly.

## Theme file structure

The JSON has two independent halves.

**`colors`**: workbench chrome. Only four keys are set (`editor.background` `#263238`, `editor.foreground` `#eeffff`, `activityBarBadge.background`, `sideBarTitle.foreground`). Everything else inherits VS Code's built-in Dark+ defaults because `uiTheme` is `vs-dark`. Styling more chrome (tabs, status bar, terminal, git decorations) means adding keys here, not touching `tokenColors`.

**`tokenColors`**: TextMate scope rules. The palette is Material Ocean and each hex has a consistent role. Reuse an existing color rather than introducing a new hex:

| Color | Role |
| --- | --- |
| `#EEFFFF` | default foreground, variables, markdown plain/table |
| `#546E7A` | comments (italic) |
| `#65737E` | muted markdown punctuation, fenced language, separators |
| `#C792EA` | keywords, storage, attribute names, markup changed, JSON key L0 |
| `#89DDFF` | operators, punctuation, tag punctuation, regexp, escape chars |
| `#f07178` | tag names, block-level variables, markup bold/italic |
| `#82AAFF` | functions, methods, decorators, links |
| `#F78C6C` | numbers, constants, parameters, units |
| `#C3E88D` | strings, inserted/added, markup headings |
| `#FFCB6B` | classes, support types, CSS classes, HTML attributes (italic) |
| `#B2CCD6` | `support.type`, CSS/SCSS/LESS property names |
| `#FF5370` | invalid, deleted, JS sub-methods, `variable.language` |
| `#C17E70` | JSON key level 4 only |

The only hexes outside that table are the four `colors` values (`#263238`, `#eeffff`, `#007acc`, `#bbbbbb`) and two dead ones, `#ffffff` and `#00000050` (see below).

## Ordering gotchas

TextMate rules are last-match-wins, and this file leans on that in a few places. Editing the earlier rule in each pair will appear to do nothing:

- `support.type` is set to `#FFCB6B` by "Class, Support", then immediately re-set to `#B2CCD6` by "Entity Types". The second wins.
- `constant.other.color` is `#ffffff` in "Colors" and `#89DDFF` in "Operator, Misc". The second wins, so the "Colors" rule is dead.
- `markup.raw.block.fenced.markdown` is `#00000050` in "Markdown - Raw Block Fenced" and `#EEFFFF` in "Markdown - Fenced Bode Block Variable". The second wins.
- JSON key colors are defined per nesting level 0 to 8 via progressively longer `meta.structure.dictionary.json` and `meta.structure.dictionary.value.json` chains. Adding a level means extending the chain, not inventing a new scope name.

## Testing a change

`sample-files/` holds fixtures for visually checking the theme across roughly fifty languages and formats: web code, six CSS dialects, seventeen backend languages, data and config formats, and tooling files. Open them in the Extension Development Host after pressing `F5`. `sample-files/README.md` maps each file to the scopes it covers.

Four fixtures reach rules nothing else does, so keep them in sync if those rules change:

- `nested.json` is the only way to see all nine JSON key-depth colors at once.
- `styles.sass` is the only fixture hitting `source.sass keyword.control`, the rule the theme calls "CSS ID's".
- `sample.php` is the only fixture covering the PHP-specific scopes.
- `sample.diff` is the only fixture covering `markup.inserted`, `markup.deleted`, and `markup.changed`.

The theme names five CSS dialects in its property-name rule (`css`, `sass`, `scss`, `less`, `stylus`, `postcss`), which is why there are six stylesheet fixtures rather than one.

The folder is excluded from the packaged `.vsix`.

## Metadata files

`README.md`, `CHANGELOG.md`, and `vsc-extension-quickstart.md` are still generator boilerplate. `.vscodeignore` keeps `.vscode/**`, `.gitignore`, and the quickstart out of the packaged `.vsix`; add new dev-only files there.
