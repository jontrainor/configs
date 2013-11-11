
if (exists("g:loaded_hg_plugin") && g:loaded_hg_plugin)
  finish
endif

let g:loaded_hg_plugin = 1

let s:blame_colors = [ 'ctermfg=2', 'ctermfg=6', 'ctermfg=1', 'ctermfg=5', 'ctermfg=3', 'ctermfg=4 cterm=bold', 'ctermfg=1 cterm=bold', 'ctermfg=3 cterm=bold', 'ctermfg=6 cterm=bold', 'ctermfg=5 cterm=bold' ]

" Automatically close quickfix buffer after a selection is made.
function! s:qf_cleanup()
  :cclose
  exe 'au! BufLeave <buffer' . bufnr("#") . '>'
endfunction

function! s:hg_status()
  let l:list=system("hg status")
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))
  if l:num == 0
    echo "No changes found"
    return
  endif

  let old_efm=&efm
  set efm=%m\ %f
  :cgete l:list
  :cope
  :setlocal modifiable
  :silent %s/^\(.*\)|| \(.\)$/\2 || \1/g
  :setlocal nomodifiable nomodified
  au BufLeave <buffer> call s:qf_cleanup()
  let &efm=old_efm
endfunction

function! s:hg_blame_hi()
  let l:names = []
  for line in getline('1','$')
    if match(line, '.* 0: *$') == -1
      let l:name = substitute(line, '^ *\([a-zA-Z]*\) .*$', '\1', 'g')
      if index(l:names, l:name) == -1
        call add(l:names, l:name)
      endif
    endif
  endfor
  for i in range(len(l:names))
    let l:name = l:names[i]
    let l:blame_color = s:blame_colors[i % len(s:blame_colors)]
    exe 'syn keyword ' . l:name . ' ' . l:name
    exe 'hi ' . l:name . ' ' . l:blame_color
  endfor
endfunction

" Show vcs blame info in a small buffer next
" to the currently open file. If this file is not
" part of some kind of repo, nothing is displayed.
function! s:hg_blame()
  " Do nothing if not a mercurial repo
  if !isdirectory('.hg') 
    return
  endif
  " If blame buffer is already open, close it and clean up
  if exists("b:blame_bufnr")
    au! BufWinLeave <buffer>
    setlocal wrap
    setlocal noscrollbind
    let l:blame_bufnr = b:blame_bufnr
    unlet b:blame_bufnr
    exe "bd " . l:blame_bufnr
    return
  endif
  " Save current line
  let line = line(".")
  " Kill wrap so lines match up
  setlocal nowrap
  " Open blame buffer and pipe hg annotate into it
  aboveleft 0vnew
  %!hg annotate -un "#"
  " Clean up unused content and resize window
  :silent %s/:.*$/:/
  let l:w = strlen(getline(1))
  exe ":vertical res " . l:w
  " Syntax coloring
  call s:hg_blame_hi()
  " Mark as blame buffer and set attributes
  setlocal nomodified readonly buftype=nofile nowrap winwidth=1 nonumber
  " Cache buffer number
  let l:blame_bufnr = bufnr("")
  " Return to current line and sync scrolls
  exe "normal " . line . "G"
  setlocal scrollbind
  wincmd p
  setlocal scrollbind
  syncbind 
  " Add clean-up hooks
  exe "au BufWinLeave <buffer> bd " . l:blame_bufnr . " | au! BufWinLeave <buffer>"
  let b:blame_bufnr = l:blame_bufnr
endfunction

function! s:hg_diff(...)
  " If diff buffer is already open, close it and clean up
  if exists("b:diff_bufnr")
    au! BufWinLeave <buffer>
    setlocal wrap
    let l:diff_bufnr = b:diff_bufnr
    unlet b:diff_bufnr
    exe "bd " . l:diff_bufnr
    return
  endif
  if a:0 == 0
    let l:count = 1
  else
    let l:count = a:1
  endif
  aboveleft vnew
  exe '%!hg hist -p -l ' . l:count . ' #'
  setlocal nowrap nomodifiable nomodified readonly buftype=nofile nonumber syn=diff
  " Add clean-up hooks
  let l:diff_bufnr = bufnr("")
  wincmd p
  exe "au BufWinLeave <buffer> bd " . l:diff_bufnr . " | au! BufWinLeave <buffer>"
  let b:diff_bufnr = l:diff_bufnr
  wincmd p
endfunction

function! s:hg_log()
  " Do nothing if not a mercurial repo
  if !isdirectory('.hg') 
    return
  endif
  " If log buffer is already open, close it and clean up
  if exists("b:log_bufnr")
    au! BufWinLeave <buffer>
    let l:log_bufnr = b:log_bufnr
    unlet b:log_bufnr
    exe "bd " . l:log_bufnr
    return
  endif
  below new
  res 15
  " setlocal scrolloff=8
  %!hg log -l 10 "#"
  setlocal nowrap nomodifiable nomodified readonly buftype=nofile nonumber
  " Add clean-up hooks
  let l:log_bufnr = bufnr("")
  wincmd p
  exe "au BufWinLeave <buffer> bd " . l:log_bufnr . " | au! BufWinLeave <buffer>"
  let b:log_bufnr = l:log_bufnr
  wincmd p
endfunction

com! -nargs=0 HGBlame call s:hg_blame()
com! -nargs=* HGDiff call s:hg_diff(<f-args>)
com! -nargs=* HGLog call s:hg_log()
com! -nargs=* HGStatus call s:hg_status()

map <F9> :HGLog<CR>
map <F10> :HGStatus<CR>
map <F11> :HGDiff<CR>
map <F12> :HGBlame<CR>

