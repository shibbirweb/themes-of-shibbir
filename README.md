# Themes of Shibbir

Two dark themes for Visual Studio Code, built around different ideas about depth.

They are not light and dark variants of one palette. Each has its own colors, so
pick whichever suits how you like your editor to feel.

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

## Install

From the Extensions view in VS Code, search for **Themes of Shibbir** and click
Install.

From the command line:

```sh
code --install-extension shibbirweb.themes-of-shibbir
```

The extension is published to both the
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=shibbirweb.themes-of-shibbir)
and [Open VSX](https://open-vsx.org/extension/shibbirweb/themes-of-shibbir), so
it also installs in VSCodium, Cursor, Gitpod, and other editors that use the
Open VSX registry.

## Activate

Open the Color Theme picker with `Cmd+K Cmd+T` on macOS or `Ctrl+K Ctrl+T` on
Windows and Linux, then choose **Themes of Shibbir: Dark Solid** or
**Themes of Shibbir: Dark Shades**.

Both entries share a prefix, so they appear next to each other in the list.

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

These themes are actively being built out, one area at a time. If some part of
the editor still looks like the stock dark theme, that area has not been styled
yet rather than being deliberately left alone.

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
