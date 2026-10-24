#!/usr/bin/env python3
"""Prepare an offline LazyVim profile; never edit the user's configuration."""
from pathlib import Path
import json, re, shutil
ROOT=Path(__file__).resolve().parents[2]
BASE=ROOT/'build/verification'
CONFIG=BASE/'config/nvim'
SOURCE=Path.home()/'.config/nvim'

def prepare():
    CONFIG.mkdir(parents=True,exist_ok=True)
    for folder in ('lua/config','lua/plugins','queries'):
        if (SOURCE/folder).exists():shutil.copytree(SOURCE/folder,CONFIG/folder,dirs_exist_ok=True)
    for name in ('lazy-lock.json','lazyvim.json'):
        if (SOURCE/name).exists():shutil.copyfile(SOURCE/name,CONFIG/name)
    # Exclude the old theme, its custom semantic overrides, and automatic SC asset setup.
    for name in ('colorscheme.lua','supercollider.lua'):
        (CONFIG/'lua/plugins'/name).unlink(missing_ok=True)
    (CONFIG/'init.lua').write_text('dofile('+json.dumps(str(ROOT/'scripts/validation/init.lua'))+')\n')
    mason=BASE/'data/mason';mason.mkdir(parents=True,exist_ok=True)
    old=Path.home()/'.local/share/nvim/mason'
    for name in ('bin','packages','share'):
        link=mason/name
        if not link.exists():link.symlink_to(old/name,target_is_directory=True)
    if (old/'registries').exists():shutil.copytree(old/'registries',mason/'registries',dirs_exist_ok=True)
    samples={
      'typescript':('sample.ts','export type Bird = { name: string; wings: number };\nexport function greet(bird: Bird): string { const count = 2; return "Hello, " + bird.name; }\nconsole.log(greet({ name: "snow", wings: 2 }));\n'),
      'tsx':('sample.tsx','type Bird = { name: string };\nfunction BirdCard(bird: Bird) { return <span>{bird.name}</span>; }\n'),
      'javascript':('sample.js','function greet(name) { const count = 2; return "Hello, " + name; }\nconsole.log(greet("bird"));\n'),
      'python':('sample.py','class Bird:\n    wings: int = 2\n    def greet(self, name: str) -> str:\n        return "Hello, " + name\nprint(Bird().greet("snow"))\n'),
      'ruby':('sample.rb','module Forest\n  class Bird\n    WINGS = 2\n    def greet(name)\n      puts "Hello, " + name\n    end\n  end\nend\n'),
      'rust':('sample.rs','struct Bird { name: String }\nfn greet(bird: &Bird) -> String { let count = 2; format!("Hello, {}", bird.name) }\nfn main() {}\n'),
      'go':('sample.go','package forest\ntype Bird struct { Name string }\nfunc greet(bird Bird) string { return "Hello, " + bird.Name }\n'),
      'lua':('sample.lua','local bird = { name = "snow", wings = 2 }\nlocal function greet(name) return "Hello, " .. name end\nprint(greet(bird.name))\n'),
      'c':('sample.c','#include <stdio.h>\nint main(void) { int count = 2; printf("%d", count); return 0; }\n'),
      'cpp':('sample.cpp','struct Bird { int wings; };\nint main() { Bird bird{2}; return bird.wings; }\n'),
      'swift':('sample.swift','struct Bird { let name: String }\nfunc greet(_ bird: Bird) -> String { return "Hello, " + bird.name }\n'),
      'bash':('sample.sh','#!/bin/bash\nname="snow"\nif [ -n "$name" ]; then printf "%s\\n" "$name"; fi\n'),
      'html':('sample.html','<section class="forest"><h1>Snow</h1><script>const wings = 2;</script></section>\n'),
      'vue':('sample.vue','<template><span>{{ name }}</span></template>\n<script setup lang="ts">const name: string = "snow";</script>\n<style scoped>span { color: blue; }</style>\n'),
      'astro':('sample.astro','---\nconst name = "snow";\n---\n<h1>{name}</h1>\n'),
      'css':('sample.css','.forest { color: blue; margin: 2px; }\n'),
      'scss':('sample.scss','$snow: blue;\n.forest { color: $snow; span { margin: 2px; } }\n'),
      'sql':('sample.sql',"SELECT name FROM birds WHERE wings = 2;\n"),
      'json':('sample.json','{"name": "snow", "wings": 2, "fluffy": true, "nest": null}\n'),
      'yaml':('sample.yaml','name: snow\nwings: 2\nfluffy: true\n'),
      'toml':('sample.toml','name = "snow"\nwings = 2\n'),
      'dockerfile':('Dockerfile','FROM alpine:latest\nENV NAME=snow\nRUN echo "$NAME"\n'),
      'make':('Makefile','bird:\n\t@echo snow\n'),
      'gomod':('go.mod','module example.com/forest\n\ngo 1.24\n'),
      'gosum':('go.sum','example.com/forest v1.0.0 h1:YWJjZA==\n'),
      'gowork':('go.work','go 1.24\nuse .\n'),
      'embedded_template':('sample.erb','<h1><%= bird.name %></h1>\n'),
      'latex':('sample.tex','\\documentclass{article}\n\\begin{document}\n\\section{Snow} $x = 2$\n\\end{document}\n'),
      'supercollider':('sample.scd','// Syntax only: no audio evaluation\nSynthDef(\\snow, { |freq=880| var signal = SinOsc.ar(freq); Out.ar(0, signal); }).add;\n'),
      'markdown':('sample.md','# Snow\n\n[Forest](https://example.com)\n\n```lua\nlocal wings = 2\n```\n\n- [x] complete\n'),
      'markdown_inline':('inline.md','**Snow** and `code` with [link](https://example.com).'),
      'vim':('sample.vim','let g:bird = "snow"\nfunction! Greet(name)\n  echo a:name\nendfunction\n'),
      'vimdoc':('sample.txt','*snow*  Snow documentation\n\tUse |snow| to visit the forest.\n\nvim:tw=78:ts=8:noet:ft=help:norl:\n'),
      'xml':('sample.xml','<forest><bird name="snow">2</bird></forest>\n'),
      'diff':('sample.diff','--- a/bird\n+++ b/bird\n@@ -1 +1 @@\n-old\n+snow\n'),
      'query':('sample.scm','(identifier) @variable\n'),
      'regex':('regex.txt','^(snow|forest)+[0-9]?$'),
      'printf':('printf.txt','%02d %s %.2f'),
      'jsdoc':('jsdoc.txt','/** @param {string} name - Bird name. */'),
      'luadoc':('luadoc.txt','@param name string\n@return string\n'),
      'luap':('luap.txt','name.field[1]'),
    }
    target=BASE/'samples';target.mkdir(parents=True,exist_ok=True)
    inventory={}
    for lang,(name,text) in samples.items():
        path=target/lang/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text)
        inventory[lang]=str(path)
    extra={
      'lean':('sample.lean','namespace Forest\nstructure Bird where\n  name : String\n  wings : Nat\ndef greet (bird : Bird) : String := "Hello, " ++ bird.name\ntheorem nonnegative (n : Nat) : 0 ≤ n := by exact Nat.zero_le n\nend Forest\n'),
      'review':('sample.re','= Snow\n\n@<b>{Forest}\n//list[bird][Bird]{\nlocal wings = 2\n//}\n'),
      'jsx':('sample.jsx','function BirdCard({name}) { return <span>{name}</span>; }\n'),
      'jsonc':('sample.jsonc','// snow\n{"name": "snow", "wings": 2}\n'),
    }
    for lang,(name,text) in extra.items():
        path=target/lang/name;path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text)
        inventory[lang]=str(path)
    (BASE/'inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
    # Minimal local project roots enable existing language servers without dependencies.
    (target/'typescript/tsconfig.json').write_text('{"compilerOptions":{"strict":true},"include":["sample.ts"]}\n')
    (target/'javascript/jsconfig.json').write_text('{"include":["sample.js"]}\n')
    (target/'python/pyrightconfig.json').write_text('{"include":["sample.py"]}\n')
    (target/'lua/.luarc.json').write_text('{}\n')
    (target/'rust/Cargo.toml').write_text('[package]\nname="forest"\nversion="0.1.0"\nedition="2021"\n[[bin]]\nname="forest"\npath="sample.rs"\n')
    (target/'go/go.mod').write_text('module example.com/forest\n\ngo 1.24\n')
    (target/'lean/lean-toolchain').write_text('leanprover/lean4:v4.34.1\n')
    print(f'Prepared {len(samples)} parser fixtures + {len(extra)} related formats at {BASE}')
if __name__=='__main__':prepare()
