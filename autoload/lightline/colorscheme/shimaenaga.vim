" Modified for Shimaenaga: namespace and palette integration.
let s:palette = v:lua.require('lightline.colorscheme.shimaenaga')
let g:lightline#colorscheme#shimaenaga#palette = lightline#colorscheme#fill(s:palette)
