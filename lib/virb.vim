"=================================================
" File: virb.vim
" Description: A Vim shell for irb and rails console
" Author: Daniel Choi <dhchoi@gmail.com>
" ================================================

if exists("g:loaded_virb") || &cp
    finish
endif
let g:loaded_virb = 1

let s:fifo = ".virb/fifo"

" split into two windows: a session buffer and a interactive buffer

function! s:focus_virb_output_window()
  if bufwinnr(s:virb_output_bufnr) == winnr()
    return
  end
  let winnr = bufwinnr(s:virb_output_bufnr)
  if winnr == -1
    " create window
    split! .virb/session
    exec "buffer" . s:virb_output_bufnr
  else
    exec winnr . "wincmd w"
  endif
endfunc

function! VirbStatusLine()
  let line =  "%<*virb* Press <ENTER> to run code on cursorline or in selection.   %r%=%-14.(%l,%c%V%)\ %P"
  return line
endfunc

split! .virb/session
setlocal autoread
let s:virb_output_bufnr = bufnr('%')
setlocal nomodifiable
setlocal nu

" in interactive buffer
wincmd p
setlocal nu
setlocal statusline=%!VirbStatusLine()

" main execution function
func! Virb() range
  let s:mtime = getftime(".virb/session")
  let cmd = ":".a:firstline.",".a:lastline."w >> .virb/fifo"
  exec cmd
  :sleep 400m
  :call VirbRefresh()
endfunc

func! VirbRefresh()
  :call s:focus_virb_output_window()
  :exec ":checktime ".s:virb_output_bufnr
  :normal G
  :wincmd p
endfunc

if !hasmapto('<Plug>VirbRun')
  nnoremap <buffer> <cr> :call Virb()<cr>
  vnoremap <buffer> <cr> :call Virb()<cr>
endif


if !hasmapto('<Plug>VirbRefresh')
  nnoremap <buffer> <space> :checkt<CR>
endif

" need a binding to update the session buffer manually
"
" TODO filetype detect *.virb to automatically turn o