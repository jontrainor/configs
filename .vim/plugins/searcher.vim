
if (exists("g:loaded_searcher_plugin") && g:loaded_searcher_plugin)
  finish
endif
let g:loaded_searcher_plugin = 1

if !exists("g:findprg")
  let g:findprg = "find . -name"
endif

" Find one or more files in the current directory
" matching {name}. If only one file is found, it
" will be opened in the current buffer, otherwise
" the list of matching files will be loaded in the
" quickfix buffer.
function! s:find_qf(name)
  " List of all matching files, ignoring errors
  let l:list=system(g:findprg . " '" . a:name . "' 2> /dev/null") 
  " Count the number of newlines
  let l:num=strlen(substitute(l:list, "[^\n]", "", "g"))

  if l:num < 1
    " Error message if file doesn't exist
    echo "File '".a:name."' not found"
    return
  endif

  if l:num == 1
    " If a single result is found, open directly
    exe "open " . substitute(l:list, "\n", "", "g")
  else
    " Otherwise, display the results in the quickfix buffer
    let old_efm=&efm
    set efm=%f
    :cgete l:list
    :cope
    " Trim trailing spacers since no line numbers or content
    :setlocal modifiable
    :silent %s/...$//g
    :setlocal nomodifiable nomodified
    au BufLeave <buffer> call s:qf_cleanup()
    let &efm=old_efm
  endif
endfunction

" Automatically close quickfix buffer after a selection is made.
function! s:qf_cleanup()
  :cclose
  exe 'au! BufLeave <buffer' . bufnr("#") . '>'
endfunction

com! -nargs=+ Grep :silent grep! <args> | :redraw!
com! -nargs=1 Find call s:find_qf(<f-args>)

" Automatically open quickfix window after grep
au QuickfixCmdPost grep cope
au QuickfixCmdPost grep setlocal nowrap

cabbrev fn Find
cabbrev gr Grep

