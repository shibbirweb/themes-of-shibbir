# Change Log

All notable changes to the Themes of Shibbir extension are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Work in progress on Dark Solid and Dark Shades: workbench chrome (activity bar, panel, status
bar, tabs, terminal, git decorations) and the full set of TextMate token rules.

### Added

- **Themes of Shibbir: Islands Dark**, a dark theme with the editor and side
  panes on near-black islands inside a lighter frame.
- **Themes of Shibbir: Islands Light**, the same island layout in light colors.
  This is the first light theme in the extension.
- Both Islands themes are complete: every workbench color key in the VS Code
  theme reference is set (editor, sidebar, panel, terminal and ANSI colors,
  tabs, status bar, title bar, menus, widgets, lists, diff and merge editors,
  notebooks, testing, debugging, source control, chat, and more), along with a
  full set of TextMate token rules and semantic token colors.

## [0.0.1] - 2026-08-16

First release. Both themes are early and cover the editor surface, comments, and
semantic tokens. Areas that are not styled yet fall back to the built-in dark
theme.

### Added

- **Themes of Shibbir: Dark Solid**, a dark theme that keeps every surface on one
  flat color so nothing but the code carries contrast.
- **Themes of Shibbir: Dark Shades**, a dark theme that steps its surfaces
  through separate depths so panes are distinguishable at a glance.
- Editor background, editor foreground, and sidebar background for both themes.
- Italic comments, in each theme's own muted tone.
- Semantic highlighting, with 18 semantic token colors per theme covering
  namespaces, classes, interfaces, enums, structs, types, type parameters,
  functions, methods, events, decorators, macros, parameters, enum members,
  variables, properties, readonly modifiers, and deprecated symbols.
- Support for VS Code 1.12 and newer. Semantic highlighting applies on 1.43 and
  newer; older builds ignore it and fall back to TextMate rules.
- Published to both the Visual Studio Marketplace and Open VSX, so the themes
  install in VSCodium, Cursor, Gitpod, and other Open VSX editors.

[Unreleased]: https://github.com/shibbirweb/themes-of-shibbir/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/shibbirweb/themes-of-shibbir/releases/tag/v0.0.1
