" unimpaired.vim - Pairs of handy bracket mappings
" Maintainer:   Tim Pope <http://tpo.pe/>
" Version:      2.1

if exists("g:loaded_unimpaired") || &cp || v:version < 700
  finish
endif
let g:loaded_unimpaired = 1

function! s:Map(...) abort
  let [mode, head, rhs; rest] = a:000
  let flags = get(rest, 0, '') . (rhs =~# '^<Plug>' ? '' : '<script>')
  let tail = ''
  let keys = get(g:, mode.'remap', {})
  if type(keys) == type({}) && !empty(keys)
    while !empty(head) && len(keys)
      if has_key(keys, head)
        let head = keys[head]
        if empty(head)
          let head = '<skip>'
        endif
        break
      endif
      let tail = matchstr(head, '<[^<>]*>$\|.$') . tail
      let head = substitute(head, '<[^<>]*>$\|.$', '', '')
    endwhile
  endif
  if head !=# '<skip>' && empty(maparg(head.tail, mode))
    return mode.'map ' . flags . ' ' . head.tail . ' ' . rhs
  endif
  return ''
endfunction

" Section: Next and previous

function! s:MapNextFamily(map, cmd, current) abort
  let prefix = '<Plug>(unimpaired-' . a:cmd
  let map = '<Plug>unimpaired'.toupper(a:map)
  let cmd = '".(v:count ? v:count : "")."'.a:cmd
  let zv = (a:cmd ==# 'l' || a:cmd ==# 'c' ? 'zv' : '')
  let end = '"<CR>'.zv
  execute 'nnoremap <silent> '.prefix.'previous) :<C-U>exe "'.cmd.'previous'.end
  execute 'nnoremap <silent> '.prefix.'next)     :<C-U>exe "'.cmd.'next'.end
  execute 'nnoremap '.prefix.'first)    :<C-U><C-R>=v:count ? v:count . "' . a:current . '" : "' . a:cmd . 'first"<CR><CR>' . zv
  execute 'nnoremap '.prefix.'last)     :<C-U><C-R>=v:count ? v:count . "' . a:current . '" : "' . a:cmd . 'last"<CR><CR>' . zv
  execute 'nnoremap <silent> '.map.'Previous :<C-U>exe "'.cmd.'previous'.end
  execute 'nnoremap <silent> '.map.'Next     :<C-U>exe "'.cmd.'next'.end
  execute 'nnoremap <silent> '.map.'First    :<C-U>exe "'.cmd.'first'.end
  execute 'nnoremap <silent> '.map.'Last     :<C-U>exe "'.cmd.'last'.end
  exe s:Map('n', '['.        a:map , prefix.'previous)')
  exe s:Map('n', ']'.        a:map , prefix.'next)')
  exe s:Map('n', '['.toupper(a:map), prefix.'first)')
  exe s:Map('n', ']'.toupper(a:map), prefix.'last)')
  if a:cmd ==# 'c' || a:cmd ==# 'l'
    execute 'nnoremap <silent> '.prefix.'pfile)  :<C-U>exe "'.cmd.'pfile'.end
    execute 'nnoremap <silent> '.prefix.'nfile)  :<C-U>exe "'.cmd.'nfile'.end
    execute 'nnoremap <silent> '.map.'PFile :<C-U>exe "'.cmd.'pfile'.end
    execute 'nnoremap <silent> '.map.'NFile :<C-U>exe "'.cmd.'nfile'.end
    exe s:Map('n', '[<C-'.toupper(a:map).'>', prefix.'pfile)')
    exe s:Map('n', ']<C-'.toupper(a:map).'>', prefix.'nfile)')
  elseif a:cmd ==# 't'
    nnoremap <silent> <Plug>(unimpaired-ptprevious) :<C-U>exe v:count1 . "ptprevious"<CR>
    nnoremap <silent> <Plug>(unimpaired-ptnext) :<C-U>exe v:count1 . "ptnext"<CR>
    execute 'nnoremap <silent> '.map.'PPrevious :<C-U>exe "p'.cmd.'previous'.end
    execute 'nnoremap <silent> '.map.'PNext :<C-U>exe "p'.cmd.'next'.end
    exe s:Map('n', '[<C-T>', '<Plug>(unimpaired-ptprevious)')
    exe s:Map('n', ']<C-T>', '<Plug>(unimpaired-ptnext)')
  endif
endfunction

call s:MapNextFamily('a', '' , 'argument')
call s:MapNextFamily('b', 'b', 'buffer')
call s:MapNextFamily('l', 'l', 'll')
call s:MapNextFamily('q', 'c', 'cc')
call s:MapNextFamily('t', 't', 'trewind')

" Section: Diff

nnoremap <silent> <Plug>(unimpaired-context-previous) :<C-U>call <SID>Context(1)<CR>
nnoremap <silent> <Plug>(unimpaired-context-next)     :<C-U>call <SID>Context(0)<CR>
vnoremap <silent> <Plug>(unimpaired-context-previous) :<C-U>exe 'normal! gv'<Bar>call <SID>Context(1)<CR>
vnoremap <silent> <Plug>(unimpaired-context-next)     :<C-U>exe 'normal! gv'<Bar>call <SID>Context(0)<CR>
onoremap <silent> <Plug>(unimpaired-context-previous) :<C-U>call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>(unimpaired-context-next)     :<C-U>call <SID>ContextMotion(0)<CR>

exe s:Map('n', '[n', '<Plug>(unimpaired-context-previous)')
exe s:Map('n', ']n', '<Plug>(unimpaired-context-next)')
exe s:Map('x', '[n', '<Plug>(unimpaired-context-previous)')
exe s:Map('x', ']n', '<Plug>(unimpaired-context-next)')
exe s:Map('o', '[n', '<Plug>(unimpaired-context-previous)')
exe s:Map('o', ']n', '<Plug>(unimpaired-context-next)')

nnoremap <silent> <Plug>unimpairedContextPrevious :<C-U>call <SID>Context(1)<CR>
nnoremap <silent> <Plug>unimpairedContextNext     :<C-U>call <SID>Context(0)<CR>
xnoremap <silent> <Plug>unimpairedContextPrevious :<C-U>exe 'normal! gv'<Bar>call <SID>Context(1)<CR>
xnoremap <silent> <Plug>unimpairedContextNext     :<C-U>exe 'normal! gv'<Bar>call <SID>Context(0)<CR>
onoremap <silent> <Plug>unimpairedContextPrevious :<C-U>call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>unimpairedContextNext     :<C-U>call <SID>ContextMotion(0)<CR>

function! s:Context(reverse) abort
  call search('^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)', a:reverse ? 'bW' : 'W')
endfunction

function! s:ContextMotion(reverse) abort
  if a:reverse
    -
  endif
  call search('^@@ .* @@\|^diff \|^[<=>|]\{7}[<=>|]\@!', 'bWc')
  if getline('.') =~# '^diff '
    let end = search('^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^@@ '
    let end = search('^@@ .* @@\|^diff ', 'Wn') - 1
    if end < 0
      let end = line('$')
    endif
  elseif getline('.') =~# '^=\{7\}'
    +
    let end = search('^>\{7}>\@!', 'Wnc')
  elseif getline('.') =~# '^[<=>|]\{7\}'
    let end = search('^[<=>|]\{7}[<=>|]\@!', 'Wn') - 1
  else
    return
  endif
  if end > line('.')
    execute 'normal! V'.(end - line('.')).'j'
  elseif end == line('.')
    normal! V
  endif
endfunction

" Section: Line operations

function! s:BlankUp() abort
  let cmd = 'put!=repeat(nr2char(10), v:count1)|silent '']+'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-up)", v:count1)'
  endif
  return cmd
endfunction

function! s:BlankDown() abort
  let cmd = 'put =repeat(nr2char(10), v:count1)|silent ''[-'
  if &modifiable
    let cmd .= '|silent! call repeat#set("\<Plug>(unimpaired-blank-down)", v:count1)'
  endif
  return cmd
endfunction

nnoremap <silent> <Plug>(unimpaired-blank-up)   :<C-U>exe <SID>BlankUp()<CR>
nnoremap <silent> <Plug>(unimpaired-blank-down) :<C-U>exe <SID>BlankDown()<CR>

nnoremap <silent> <Plug>unimpairedBlankUp   :<C-U>exe <SID>BlankUp()<CR>
nnoremap <silent> <Plug>unimpairedBlankDown :<C-U>exe <SID>BlankDown()<CR>

exe s:Map('n', '[<Space>', '<Plug>(unimpaired-blank-up)')
exe s:Map('n', ']<Space>', '<Plug>(unimpaired-blank-down)')

function! s:ExecMove(cmd) abort
  let old_fdm = &foldmethod
  if old_fdm !=# 'manual'
    let &foldmethod = 'manual'
  endif
  normal! m`
  silent! exe a:cmd
  norm! ``
  if old_fdm !=# 'manual'
    let &foldmethod = old_fdm
  endif
endfunction

function! s:Move(cmd, count, map) abort
  call s:ExecMove('move'.a:cmd.a:count)
  silent! call repeat#set("\<Plug>(unimpaired-move-".a:map.")", a:count)
endfunction

function! s:MoveSelectionUp(count) abort
  call s:ExecMove("'<,'>move'<--".a:count)
  silent! call repeat#set("\<Plug>(unimpaired-move-selection-up)", a:count)
endfunction

function! s:MoveSelectionDown(count) abort
  call s:ExecMove("'<,'>move'>+".a:count)
  silent! call repeat#set("\<Plug>(unimpaired-move-selection-down)", a:count)
endfunction

nnoremap <silent> <Plug>(unimpaired-move-up)            :<C-U>call <SID>Move('--',v:count1,'up')<CR>
nnoremap <silent> <Plug>(unimpaired-move-down)          :<C-U>call <SID>Move('+',v:count1,'down')<CR>
noremap  <silent> <Plug>(unimpaired-move-selection-up)   :<C-U>call <SID>MoveSelectionUp(v:count1)<CR>
noremap  <silent> <Plug>(unimpaired-move-selection-down) :<C-U>call <SID>MoveSelectionDown(v:count1)<CR>
nnoremap <silent> <Plug>unimpairedMoveUp            :<C-U>call <SID>Move('--',v:count1,'up')<CR>
nnoremap <silent> <Plug>unimpairedMoveDown          :<C-U>call <SID>Move('+',v:count1,'down')<CR>
noremap  <silent> <Plug>unimpairedMoveSelectionUp   :<C-U>call <SID>MoveSelectionUp(v:count1)<CR>
noremap  <silent> <Plug>unimpairedMoveSelectionDown :<C-U>call <SID>MoveSelectionDown(v:count1)<CR>

exe s:Map('n', '[e', '<Plug>(unimpaired-move-up)')
exe s:Map('n', ']e', '<Plug>(unimpaired-move-down)')
exe s:Map('x', '[e', '<Plug>(unimpaired-move-selection-up)')
exe s:Map('x', ']e', '<Plug>(unimpaired-move-selection-down)')

" Section: Option toggling

function! s:StatuslineRefresh() abort
  let &l:readonly = &l:readonly
  return ''
endfunction

function! s:Toggle(op) abort
  call s:StatuslineRefresh()
  return eval('&'.a:op) ? 'no'.a:op : a:op
endfunction

function! s:CursorOptions() abort
  return &cursorline && &cursorcolumn ? 'nocursorline nocursorcolumn' : 'cursorline cursorcolumn'
endfunction

function! s:option_map(letter, option, mode) abort
  exe 'nmap <script> <Plug>(unimpaired-enable)' .a:letter ':<C-U>'.a:mode.' '.a:option.'<C-R>=<SID>StatuslineRefresh()<CR><CR>'
  exe 'nmap <script> <Plug>(unimpaired-disable)'.a:letter ':<C-U>'.a:mode.' no'.a:option.'<C-R>=<SID>StatuslineRefresh()<CR><CR>'
  exe 'nmap <script> <Plug>(unimpaired-toggle)' .a:letter ':<C-U>'.a:mode.' <C-R>=<SID>Toggle("'.a:option.'")<CR><CR>'
endfunction

nmap <script> <Plug>(unimpaired-enable)b  :<C-U>set background=light<CR>
nmap <script> <Plug>(unimpaired-disable)b :<C-U>set background=dark<CR>
nmap <script> <Plug>(unimpaired-toggle)b  :<C-U>set background=<C-R>=&background == "dark" ? "light" : "dark"<CR><CR>
call s:option_map('c', 'cursorline', 'setlocal')
call s:option_map('-', 'cursorline', 'setlocal')
call s:option_map('_', 'cursorline', 'setlocal')
" call s:option_map('u', 'cursorcolumn', 'setlocal')
" call s:option_map('<Bar>', 'cursorcolumn', 'setlocal')
nmap <script> <Plug>(unimpaired-enable)d  :<C-U>diffthis<CR>
nmap <script> <Plug>(unimpaired-disable)d :<C-U>diffoff<CR>
nmap <script> <Plug>(unimpaired-toggle)d  :<C-U><C-R>=&diff ? "diffoff" : "diffthis"<CR><CR>
call s:option_map('h', 'hlsearch', 'set')
call s:option_map('i', 'ignorecase', 'set')
call s:option_map('l', 'list', 'setlocal')
call s:option_map('n', 'number', 'setlocal')
call s:option_map('r', 'relativenumber', 'setlocal')
call s:option_map('s', 'spell', 'setlocal')
call s:option_map('w', 'wrap', 'setlocal')
if empty(maparg('<Plug>(unimpaired-toggle)z', 'n'))
  call s:option_map('z', 'spell', 'setlocal')
endif
nmap <script> <Plug>(unimpaired-enable)v  :<C-U>set virtualedit+=all<CR>
nmap <script> <Plug>(unimpaired-disable)v :<C-U>set virtualedit-=all<CR>
nmap <script> <Plug>(unimpaired-toggle)v  :<C-U>set <C-R>=(&virtualedit =~# "all") ? "virtualedit-=all" : "virtualedit+=all"<CR><CR>
nmap <script> <Plug>(unimpaired-enable)x  :<C-U>set cursorline cursorcolumn<CR>
nmap <script> <Plug>(unimpaired-disable)x :<C-U>set nocursorline nocursorcolumn<CR>
nmap <script> <Plug>(unimpaired-toggle)x  :<C-U>set <C-R>=<SID>CursorOptions()<CR><CR>

function! s:ColorColumn(should_clear) abort
  if !empty(&colorcolumn)
    let s:colorcolumn = &colorcolumn
  endif
  return a:should_clear ? '' : get(s:, 'colorcolumn', get(g:, 'unimpaired_colorcolumn', '+1'))
endfunction
nmap <script> <Plug>(unimpaired-enable)t  :<C-U>set colorcolumn=<C-R>=<SID>ColorColumn(0)<CR><CR>
nmap <script> <Plug>(unimpaired-disable)t :<C-U>set colorcolumn=<C-R>=<SID>ColorColumn(1)<CR><CR>
nmap <script> <Plug>(unimpaired-toggle)t  :<C-U>set colorcolumn=<C-R>=<SID>ColorColumn(!empty(&cc))<CR><CR>

exe s:Map('n', 'yo', '<Plug>(unimpaired-toggle)')
exe s:Map('n', '[o', '<Plug>(unimpaired-enable)')
exe s:Map('n', ']o', '<Plug>(unimpaired-disable)')
exe s:Map('n', 'yo<Esc>', '<Nop>')
exe s:Map('n', '[o<Esc>', '<Nop>')
exe s:Map('n', ']o<Esc>', '<Nop>')

function! s:RestorePaste() abort
  if exists('s:paste')
    let &paste = s:paste
    let &mouse = s:mouse
    unlet s:paste
    unlet s:mouse
  endif
  autocmd! unimpaired_paste
endfunction

function! s:SetupPaste() abort
  let s:paste = &paste
  let s:mouse = &mouse
  set paste
  set mouse=
  augroup unimpaired_paste
    autocmd!
    autocmd InsertLeave * call s:RestorePaste()
    if exists('##ModeChanged')
      autocmd ModeChanged *:n call s:RestorePaste()
    else
      autocmd CursorHold,CursorMoved * call s:RestorePaste()
    endif
  augroup END
endfunction

nnoremap <silent> <Plug>unimpairedPaste :call <SID>SetupPaste()<CR>
nmap <script><silent> <Plug>(unimpaired-paste) :<C-U>call <SID>SetupPaste()<CR>

nmap <script><silent> <Plug>(unimpaired-enable)p  :<C-U>call <SID>SetupPaste()<CR>O
nmap <script><silent> <Plug>(unimpaired-disable)p :<C-U>call <SID>SetupPaste()<CR>o
nmap <script><silent> <Plug>(unimpaired-toggle)p  :<C-U>call <SID>SetupPaste()<CR>0C

" Section: Put

function! s:putline(how, map) abort
  let reg = v:register
  let [body, type] = [getreg(reg), getregtype(reg)]
  if reg =~ '[:%.]' " detect read-only registers
    let [body_save, type_save] = [getreg('"'), getregtype('"')]
    let reg = '"'
    call setreg('"', body, type)
  endif
  if type ==# 'V'
    exe 'normal! "'.reg.a:how
  else
    call setreg(reg, body, 'l')
    exe 'normal! "'.reg.a:how
    call setreg(reg, body, type)
  endif
  if exists('l:body_save')
    call setreg('"', body_save, type_save)
  endif
  silent! call repeat#set("\<Plug>(unimpaired-put-".a:map.")")
endfunction

nnoremap <silent> <Plug>(unimpaired-put-above) :call <SID>putline('[p', 'above')<CR>
nnoremap <silent> <Plug>(unimpaired-put-below) :call <SID>putline(']p', 'below')<CR>
nnoremap <silent> <Plug>unimpairedPutAbove :call <SID>putline('[p', 'above')<CR>
nnoremap <silent> <Plug>unimpairedPutBelow :call <SID>putline(']p', 'below')<CR>

exe s:Map('n', '[p', '<Plug>(unimpaired-put-above)')
exe s:Map('n', ']p', '<Plug>(unimpaired-put-below)')
exe s:Map('n', '[P', '<Plug>(unimpaired-put-above)')
exe s:Map('n', ']P', '<Plug>(unimpaired-put-below)')

" vim:set sw=2 sts=2:
