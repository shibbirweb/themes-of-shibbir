# Themes of Shibbir

[![Visual Studio Marketplace](https://img.shields.io/visual-studio-marketplace/v/shibbirweb.themes-of-shibbir?label=Marketplace&color=1E2227)](https://marketplace.visualstudio.com/items?itemName=shibbirweb.themes-of-shibbir)
[![Installs](https://img.shields.io/visual-studio-marketplace/i/shibbirweb.themes-of-shibbir?label=Installs&color=1E2227)](https://marketplace.visualstudio.com/items?itemName=shibbirweb.themes-of-shibbir)
[![Rating](https://img.shields.io/visual-studio-marketplace/r/shibbirweb.themes-of-shibbir?label=Rating&color=1E2227)](https://marketplace.visualstudio.com/items?itemName=shibbirweb.themes-of-shibbir&ssr=false#review-details)
[![Open VSX](https://img.shields.io/open-vsx/v/shibbirweb/themes-of-shibbir?label=Open%20VSX&color=1B222A)](https://open-vsx.org/extension/shibbirweb/themes-of-shibbir)
[![License](https://img.shields.io/badge/License-MIT-1B222A)](LICENSE)

Four themes for Visual Studio Code: two dark themes built around different
ideas about depth, plus the Islands pair, one dark and one light.

Each has its own colors rather than being a variant of another, so pick
whichever suits how you like your editor to feel.

## The themes

### Themes of Shibbir: Dark Solid

One flat surface color across the whole window. The editor, sidebar, panel,
status bar, and tabs all sit at the same depth, separated only by thin borders.
Syntax colors are vivid and saturated, so the code is the only thing with
contrast on screen.

Pick this if you find layered chrome noisy and want your attention pulled
entirely to the text.

### Themes of Shibbir: Dark Shades

Surfaces step through five distinct depths, from the darkest status bar up to the
lightest editor background. Syntax colors are muted and desaturated to match.

Pick this if you like being able to tell panes apart at a glance without reading
them, and prefer a softer palette for long sessions.

### Themes of Shibbir: Islands Dark

The editor and sidebar sit on near-black islands inside a lighter frame, so
each pane reads as its own surface. Syntax colors are warm and calm: orange
keywords, green strings, cyan numbers, blue function declarations, and purple
fields and constants.

Pick this if you like clearly separated panes with a restrained palette.

### Themes of Shibbir: Islands Light

White islands on a soft gray frame. Syntax colors are crisp and dark: navy
keywords, green strings, teal function declarations, and purple fields.

Pick this for the same island layout in a light editor.

Both Islands themes style the whole window, not just the editor: sidebar,
panel, terminal (including ANSI colors), tabs, status bar, menus, widgets,
diff and merge editors, notebooks, source control, and chat. In the diff
editor, deleted lines show gray rather than red, and changed lines blue.

## Where it is published

| Registry | Listing | Identifier |
| --- | --- | --- |
| Visual Studio Marketplace | [marketplace.visualstudio.com](https://marketplace.visualstudio.com/items?itemName=shibbirweb.themes-of-shibbir) | `shibbirweb.themes-of-shibbir` |
| Open VSX | [open-vsx.org](https://open-vsx.org/extension/shibbirweb/themes-of-shibbir) | `shibbirweb/themes-of-shibbir` |

Both listings carry the same build. Open VSX is what VSCodium, Cursor, Gitpod,
Eclipse Theia, and other non-Microsoft builds read from, so the extension
installs there as well as in VS Code.

## Install

From the Extensions view in VS Code, search for **Themes of Shibbir** and click
Install.

From the command line:

```sh
code --install-extension shibbirweb.themes-of-shibbir
```

For an editor that uses Open VSX, install it from that editor's own Extensions
view, or download the `.vsix` from the
[Open VSX listing](https://open-vsx.org/extension/shibbirweb/themes-of-shibbir)
and run:

```sh
codium --install-extension themes-of-shibbir-0.1.0.vsix
```

## Activate

Open the Color Theme picker with `Cmd+K Cmd+T` on macOS or `Ctrl+K Ctrl+T` on
Windows and Linux, then choose any **Themes of Shibbir** entry: Dark Solid, Dark Shades,
Islands Dark, or Islands Light.

All entries share a prefix, so they appear next to each other in the list.

To set one as your default without opening the picker, add this to your
`settings.json`:

```json
{
  "workbench.colorTheme": "Themes of Shibbir: Dark Solid"
}
```

## Compatibility

Requires VS Code 1.12 or newer, which covers every release since April 2017.

Semantic highlighting is included and applies on VS Code 1.43 and newer. On older
builds it is ignored and syntax coloring falls back to TextMate rules, so the
themes still work, just with less precise coloring in languages that ship a
semantic token provider.

## Status

The Islands themes are complete. Dark Solid and Dark Shades are actively being
built out, one area at a time. If some part of the editor still looks like the
stock VS Code theme in one of those two, that area has not been styled yet
rather than being deliberately left alone.

Suggestions for what to cover next are welcome.

## Feedback

Bug reports and requests go to
[GitHub Issues](https://github.com/shibbirweb/themes-of-shibbir/issues).

If a specific language reads badly, mentioning the language and the construct is
much more useful than a general report, since themes are tuned scope by scope.

## Support

If these themes are useful to you, you can
[buy me a coffee](https://buymeacoffee.com/shibbirweb).

## License

[MIT](LICENSE), Copyright (c) Md. Shibbir Ahmed.
