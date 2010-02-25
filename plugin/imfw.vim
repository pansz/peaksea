" Vim plugin file --- imfw.vim "vim Input Method FrameWork"
" Author:	Pan, Shi Zhu <Go to the following URL for my email>
" URL:		http://vim.sourceforge.net/scripts/script.php?script_id=760
" Last Change:	21 Dec 2009
" License:	GNU Lesser General Public License
"
"	Comments and e-mails are welcomed, thanks.
"
" Description:
" 	This plugin is inspired by vimim and ywvim. There are some design
" 	considerations:
" 	1. users can write their own im engine easily, not just provide their
" 	own code-table（码表）, providing code-table isn't enough for a good
" 	input method. Some advanced user may need to DIY their own parsing
" 	engine.
" 	2. input method should work for insert mode, normal mode and command
" 	mode.
"
" Note: None here.

" sanity check
if &cp | finish | endif
if v:version<700 | finish | endif

" exit when vimim present
if exists("b:loaded_vimim") | finish | endif
let b:loaded_vimim=1
" exit when ywvim present
if exists("s:loaded_ywvim") | finish | endif
let s:loaded_ywvim = 1

scriptencoding utf-8

function! imfw#save_option()
  let s:saved_cpo=&cpo
  let s:saved_lazyredraw=&lazyredraw
  let s:saved_hlsearch=&hlsearch
  let s:saved_pumheight=&pumheight
  let s:saved_completeopt=&completeopt
  let s:saved_completefunc=&completefunc
endfunc

function! imfw#set_im_option()
  let &l:completefunc='imfw#cfunc'
  let &l:completeopt='menuone'
  let &pumheight=10
  set nolazyredraw
  set hlsearch
endfunc

function! imfw#load_option()
  let &cpo=s:saved_cpo
  let &lazyredraw=s:saved_lazyredraw
  let &hlsearch=s:saved_hlsearch
  let &pumheight=s:saved_pumheight
  let &completeopt=s:completeopt
  let &completefunc=s:completefunc
endfunc

function! imfw#cfunc(findstart, base)
  if a:findstart == 1
    return 0
  endif
  let keyb = a:base
  return [keyb . "cfunc"]
endfunc

function! imfw#onekey()
  call imfw#set_im_option()
endfunc

function! imfw#init()
  call imfw#save_option()
endfunc

call imfw#init()

call imfw#onekey()

" vim:et:nosta:sw=2:ts=8:
