#!/usr/bin/env python3
"""Remove VCL Ribbon/ScreenTips from UMenu.dfm and simplify ActionManager for native menu."""

import re
import sys
from pathlib import Path


def strip_object_block(text: str, object_name: str) -> str:
    marker = f"  object {object_name}:"
    start = text.find(marker)
    if start < 0:
        print(f"  skip {object_name} (not found)")
        return text
    rest = text[start:]
    depth = 0
    for m in re.finditer(r"(?m)^(\s+)(object \w|end\s*$)", rest):
        kind = m.group(2)
        if kind.startswith("object"):
            depth += 1
        else:
            depth -= 1
            if depth == 0:
                end = start + m.end()
                if end < len(text) and text[end] == "\n":
                    end += 1
                return text[:start] + text[end:]
    raise RuntimeError(f"Could not find end of object {object_name}")


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(
        "Retaguarda/Cliente/Cadastros/Tela/UMenu.dfm"
    )
    text = path.read_text(encoding="utf-8", errors="replace")

    for obj in ("Ribbon", "ScreenTipsManager1"):
        text = strip_object_block(text, obj)

    text = re.sub(
        r"    ActionBars = <.*?>\s*\n(?=\s*LargeImages = )",
        "    ActionBars = <>\n",
        text,
        count=1,
        flags=re.DOTALL,
    )
    text = text.replace("StyleName = 'Ribbon - Silver'\n", "")

    text = text.replace(
        "  object JvTabBar: TJvTabBar\n"
        "    AlignWithMargins = True\n"
        "    Left = 3\n"
        "    Top = 146\n"
        "    Width = 1014\n",
        "  object JvTabBar: TJvTabBar\n"
        "    Align = alTop\n"
        "    Width = 1014\n",
    )

    text = re.sub(
        r"  object JvPageList: TJvPageList\n"
        r"    Left = 0\n"
        r"    Top = 172\n",
        "  object JvPageList: TJvPageList\n",
        text,
        count=1,
    )

    path.write_text(text, encoding="utf-8")
    print(f"Updated {path} ({path.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
