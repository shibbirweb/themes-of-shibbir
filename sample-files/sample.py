"""Python sample: docstrings, decorators, type hints, comprehensions."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from enum import Enum
from functools import lru_cache
from pathlib import Path
from typing import Any, Iterable, Optional

HEX_PATTERN = re.compile(r"^#(?:[0-9a-fA-F]{3}){1,2}$")
DEFAULT_HEX = "#EEFFFF"
MAX_DEPTH = 8
SCALE = 1.5e-3


class TokenKind(Enum):
    COMMENT = "comment"
    KEYWORD = "keyword"
    STRING = "string"
    NUMBER = "constant.numeric"


@dataclass(frozen=True, slots=True)
class Swatch:
    label: str
    hex_value: str = DEFAULT_HEX
    tags: list[str] = field(default_factory=list)

    def __post_init__(self) -> None:
        if not HEX_PATTERN.match(self.hex_value):
            raise ValueError(f"Invalid hex: {self.hex_value!r}")

    def __repr__(self) -> str:
        return f"<Swatch {self.label} {self.hex_value}>"


class ThemeRegistry:
    """Holds swatches and loads them from disk."""

    def __init__(self, name: str, *, strict: bool = False) -> None:
        self.name = name
        self.strict = strict
        self._swatches: dict[str, Swatch] = {}

    @property
    def size(self) -> int:
        return len(self._swatches)

    @staticmethod
    def normalize(value: str) -> str:
        return value.strip().upper()

    @classmethod
    def from_file(cls, path: Path) -> ThemeRegistry:
        raw: dict[str, Any] = json.loads(path.read_text(encoding="utf-8"))
        registry = cls(raw.get("name", "unnamed"))

        for label, hex_value in raw.get("colors", {}).items():
            registry.add(Swatch(label=label, hex_value=hex_value))

        return registry

    def add(self, swatch: Swatch) -> None:
        self._swatches[swatch.label] = swatch

    def find(self, label: str) -> Optional[Swatch]:
        return self._swatches.get(label)

    def __iter__(self) -> Iterable[Swatch]:
        yield from self._swatches.values()


@lru_cache(maxsize=128)
def luminance(hex_value: str) -> float:
    stripped = hex_value.lstrip("#")
    red, green, blue = (int(stripped[i : i + 2], 16) for i in (0, 2, 4))
    return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255


def classify(swatches: Iterable[Swatch]) -> dict[str, list[str]]:
    buckets: dict[str, list[str]] = {"dark": [], "light": []}

    for swatch in swatches:
        key = "light" if luminance(swatch.hex_value) > 0.5 else "dark"
        buckets[key].append(swatch.label)

    return {key: sorted(value) for key, value in buckets.items() if value}


def main() -> int:
    registry = ThemeRegistry("Themes of Shibbir", strict=True)
    registry.add(Swatch("background", "#263238", tags=["ui"]))
    registry.add(Swatch("keyword", "#C792EA"))

    labels = [swatch.label for swatch in registry if swatch.hex_value != DEFAULT_HEX]
    lookup = {label: index for index, label in enumerate(labels)}

    try:
        print(json.dumps(classify(registry), indent=2))
    except (TypeError, ValueError) as error:
        print(f"failed: {error}")
        return 1
    else:
        print(f"{registry.size} swatches, {len(lookup)} indexed")
    finally:
        del lookup

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
