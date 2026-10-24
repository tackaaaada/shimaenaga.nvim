#!/usr/bin/env python3
"""Run the standalone checks for the Neovim theme."""
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def check():
    for name in ('check.lua', 'check-color-scheme.lua', 'check-color-preview.lua',
                 'check-lualine.lua', 'check-backgrounds.lua'):
        subprocess.run(['nvim', '--headless', '--clean', '-l', str(ROOT/'scripts'/name)], check=True)
    print('PASS: Neovim theme, palettes, highlights, previews, transparency, and statusline.')


if __name__ == '__main__':
    check()
