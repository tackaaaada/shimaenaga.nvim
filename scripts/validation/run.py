#!/usr/bin/env python3
"""Run or open the isolated profile, using only installed plugins and parsers."""
from pathlib import Path
import os,subprocess,sys
from prepare import prepare,ROOT,BASE
prepare()
env=os.environ.copy()
for kind in ('CONFIG','DATA','STATE','CACHE'):
    path=BASE/kind.lower();path.mkdir(parents=True,exist_ok=True)
    env[f'XDG_{kind}_HOME']=str(path)
# Bypass mise's wrappers in this isolated XDG profile; use installed runtimes directly.
runtime=[]
for tool in ('node','ruby','go','python'):
    path=Path.home()/f'.local/share/mise/installs/{tool}/latest/bin'
    if tool=='node' and (Path.home()/'.local/share/mise/installs/node/22.22.2/bin').is_dir():
        path=Path.home()/'.local/share/mise/installs/node/22.22.2/bin'
    if path.is_dir():runtime.append(str(path.resolve()))
env['PATH']=':'.join(runtime+[env['PATH']])
runtime_dir=BASE/'runtime';runtime_dir.mkdir(exist_ok=True);runtime_dir.chmod(0o700)
env['XDG_RUNTIME_DIR']=str(runtime_dir)
env['SHIMAENAGA_STYLE']=os.environ.get('SHIMAENAGA_STYLE','yukiyo')
env['SHIMAENAGA_TRANSPARENT']=os.environ.get('SHIMAENAGA_TRANSPARENT','1')
if '--interactive' in sys.argv:
    command=['nvim',str(BASE/'samples/typescript/sample.ts')]
else:
    script='check_oil.lua' if '--oil' in sys.argv else 'check_lualine_profile.lua' if '--lualine' in sys.argv else 'verify.lua'
    command=['nvim','--headless','-c',f"luafile {ROOT}/scripts/validation/{script}"]
raise SystemExit(subprocess.call(command,env=env,cwd=BASE))
