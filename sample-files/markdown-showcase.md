# Heading level 1

Plain paragraph text. This theme styles markdown heavily, so nearly every
construct below maps to its own rule.

## Heading level 2

### Heading level 3

#### Heading level 4

##### Heading level 5

###### Heading level 6

---

## Inline emphasis

Regular text, then **bold text**, then *italic text*, then ***bold italic text***,
then `inline raw code`, then ~~strikethrough~~.

<u>Underlined via inline HTML</u> and <strong>bold via inline HTML</strong>.

## Links

An [inline link](https://code.visualstudio.com) with a title.

A [reference link][vscode-docs] pointing at a labelled definition.

A bare autolink: <https://example.com>

An image: ![Swatch preview](./swatch.png "Swatch title")

[vscode-docs]: https://code.visualstudio.com/api/extension-guides/color-theme "Color theme guide"

## Blockquote

> A single level blockquote.
>
> > A nested blockquote with **bold** inside it.
>
> Back to the first level.

## Lists

- Unordered item one
- Unordered item two
  - Nested item
  - Another nested item with `code`
- Unordered item three

1. Ordered item one
2. Ordered item two
   1. Nested ordered item
3. Ordered item three

- [ ] Incomplete task
- [x] Completed task

## Table

| Token       | Hex       | Style      |
| ----------- | --------- | ---------- |
| Comment     | `#546E7A` | italic     |
| Keyword     | `#C792EA` | normal     |
| String      | `#C3E88D` | normal     |
| Function    | `#82AAFF` | normal     |
| Number      | `#F78C6C` | normal     |

## Fenced code blocks

```javascript
const palette = {
  background: '#263238',
  foreground: '#EEFFFF',
};

function describe(theme) {
  return `${theme.name} has ${Object.keys(theme.colors).length} colors`;
}
```

```php
<?php

namespace App\Models;

final class Swatch extends BaseModel
{
    public const DEFAULT_HEX = '#EEFFFF';
}
```

```scss
.palette {
  background-color: #263238;

  &__swatch {
    aspect-ratio: 1 / 1;
  }
}
```

```
An unlabelled fenced block, which uses a different scope
than the labelled ones above.
```

    An indented code block, four spaces deep.

## Footnote and escapes

Here is a footnote reference[^1].

[^1]: The footnote body.

Escaped characters: \*not italic\*, \_not italic\_, \`not code\`.

## Horizontal rules

***

___
