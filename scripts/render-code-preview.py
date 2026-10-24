#!/usr/bin/env python3
"""Render the bilingual README's two-theme TypeScript preview from the palette."""

from pathlib import Path
import math
import re
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
PALETTE = ROOT / "lua/shimaenaga/palette.lua"
OUTPUT = ROOT / "assets/code-preview.svg"
SVG = "http://www.w3.org/2000/svg"

# The sample intentionally covers the theme's syntax roles without loading a
# parser or a user's Neovim configuration. It is an illustration, not a capture.
LINES = [
    [("// Hokkaido in winter", "comment")],
    [("type ", "keyword"), ("Scene", "type"), (" = ", "operator"), ("{", "bracket")],
    [("  birds", "text"), (": ", "delimiter"), ("number", "type"), (";", "delimiter")],
    [("  place", "text"), (": ", "delimiter"), ('"forest"', "string"), (" | ", "operator"), ('"drift ice"', "string"), (";", "delimiter")],
    [("}", "bracket"), (";", "delimiter")],
    [],
    [("function ", "keyword"), ("greet", "function"), ("(", "bracket"), ("scene", "text"), (": ", "delimiter"), ("Scene", "type"), (")", "bracket"), (" {", "bracket")],
    [("  const ", "keyword"), ("count", "text"), (" = ", "operator"), ("scene", "text"), (".", "delimiter"), ("birds", "text"), (";", "delimiter")],
    [("  if ", "keyword"), ("(", "bracket"), ("count", "text"), (" > ", "operator"), ("0", "number"), (") {", "bracket")],
    [("    return ", "keyword"), ("`Hello, ", "string"), ("${", "bracket"), ("count", "text"), ("}", "bracket"), (" shimaenaga!`", "string"), (";", "delimiter")],
    [("  }", "bracket")],
    [("  return ", "keyword"), ('"The snow is quiet."', "string"), (";", "delimiter")],
    [("}", "bracket")],
]


def tag(parent, name, **attrs):
    return ET.SubElement(parent, f"{{{SVG}}}{name}", {k.replace("_", "-"): str(v) for k, v in attrs.items()})


def palettes():
    source = PALETTE.read_text(encoding="utf-8")
    result = {}
    for style in ("yukiyo", "ryuhyo"):
        match = re.search(rf"M\.{style}\s*=\s*\{{(.*?)\n\}}", source, re.S)
        if not match:
            raise ValueError(f"Missing {style} palette")
        colors = dict(re.findall(r'\b(\w+)\s*=\s*"(#[0-9a-fA-F]{6})"', match.group(1)))
        required = {"bg", "bg_dark", "fg", "fg_dark", "comment", "purple", "blue", "cyan", "green", "orange", "magenta"}
        if missing := required - colors.keys():
            raise ValueError(f"Missing {style} colors: {sorted(missing)}")
        colors["bracket"] = blend(colors["orange"], colors["fg"], 0.2)
        result[style] = colors
    return result


def blend(first, second, amount):
    values = []
    for offset in (1, 3, 5):
        a = int(first[offset : offset + 2], 16)
        b = int(second[offset : offset + 2], 16)
        values.append(math.floor(a + (b - a) * amount + 0.5))
    return "#" + "".join(f"{value:02x}" for value in values)


def draw_card(root, defs, x, style, label, colors):
    y, width, height = 108, 720, 570
    clip = tag(defs, "clipPath", id=f"clip-{style}")
    tag(clip, "rect", x=x, y=y, width=width, height=height, rx=19)

    title = tag(root, "text", x=x + 3, y=67, fill="#243349", font_size=29, font_weight=700)
    title.text = label

    group = tag(root, "g", clip_path=f"url(#clip-{style})")
    tag(group, "rect", x=x, y=y, width=width, height=height, fill=colors["bg"])
    tag(group, "rect", x=x, y=y, width=width, height=59, fill=colors["bg_dark"])
    tab = tag(group, "text", x=x + 27, y=y + 38, fill=colors["fg"], font_size=19)
    tab.text = "scene.ts"
    dot = tag(group, "circle", cx=x + width - 29, cy=y + 29, r=5, fill=colors["cyan"])
    dot.tail = None

    roles = {
        "comment": colors["comment"],
        "keyword": colors["purple"],
        "type": colors["cyan"],
        "function": colors["blue"],
        "string": colors["green"],
        "number": colors["orange"],
        "operator": colors["magenta"],
        "bracket": colors["bracket"],
        "delimiter": colors["fg_dark"],
        "text": colors["fg"],
    }
    for number, runs in enumerate(LINES, 1):
        baseline = y + 99 + (number - 1) * 34
        gutter = tag(group, "text", x=x + 25, y=baseline, fill=colors["comment"], font_size=16)
        gutter.text = f"{number:02}"
        line = tag(group, "text", x=x + 79, y=baseline, fill=colors["fg"], font_size=19)
        line.set("xml:space", "preserve")
        for chunk, role in runs:
            span = tag(line, "tspan", fill=roles[role])
            span.text = chunk

    footer_y = y + height - 42
    tag(group, "rect", x=x, y=footer_y, width=width, height=42, fill=colors["bg_dark"])
    tag(group, "rect", x=x, y=footer_y, width=116, height=42, fill=colors["blue"])
    mode = tag(group, "text", x=x + 18, y=footer_y + 28, fill=colors["bg"], font_size=17, font_weight=700)
    mode.text = "NORMAL"
    status = tag(group, "text", x=x + 137, y=footer_y + 28, fill=colors["fg"], font_size=16)
    status.text = "scene.ts  ·  TypeScript"
    tag(root, "rect", x=x, y=y, width=width, height=height, rx=19, fill="none", stroke="#cbd5e1", stroke_width=2)


def main():
    colors = palettes()
    ET.register_namespace("", SVG)
    root = ET.Element(f"{{{SVG}}}svg", {"viewBox": "0 0 1560 720", "role": "img", "aria-labelledby": "title desc"})
    tag(root, "title", id="title").text = "Shimaenaga code color preview: Yukiyo and Ryuhyo"
    tag(root, "desc", id="desc").text = "The same TypeScript sample rendered with the dark Yukiyo and light Ryuhyo palettes."
    defs = tag(root, "defs")
    tag(root, "rect", x=0, y=0, width=1560, height=720, fill="#f4f6f9")
    root.set("font-family", "DejaVu Sans Mono, Noto Sans Mono, monospace")
    draw_card(root, defs, 40, "yukiyo", "Yukiyo  /  雪夜", colors["yukiyo"])
    draw_card(root, defs, 800, "ryuhyo", "Ryuhyo  /  流氷", colors["ryuhyo"])
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(root).write(OUTPUT, encoding="utf-8", xml_declaration=True)
    print(OUTPUT)


if __name__ == "__main__":
    main()
