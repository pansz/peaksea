" manpageview.vim : extra commands for manual-handling
" Author:	Charles E. Campbell, Jr.
" Date:		Jun 08, 2004
" Version:	7
"
" please read :help manpageview for usage, options, etc

" prevent double-loading
if &cp || exists("s:loaded_manpageview")
 finish
endif
let s:loaded_manpageview = 1

" set up default manual-window opening option
if !exists("g:manpageview_winopen")
 let g:manpageview_winopen= "hsplit"
elseif g:manpageview_winopen == "only" && !has("mksession")
 echomsg "***g:manpageview_winopen<".g:manpageview_winopen."> not supported w/o +mksession"
 let g:manpageview_winopen= "hsplit"
endif

" Public Interface:
if !hasmapto('<Plug>ManPageView')
  nmap <unique> K <Plug>ManPageView
endif
nmap <silent> <script> <Plug>ManPageView  :silent call <SID>ManPageView(expand("<cword>"))<CR>
com! -nargs=*	Man silent! call <SID>ManPageView(<f-args>)

if !exists("g:manpageview_options")
 let g:manpageview_options= ""
endif

" ---------------------------------------------------------------------

" ManPageView: view a manual-page, accepts three formats:
"    :call ManPageView("topic")
"    :call ManPageView(booknumber,"topic")
"    :call ManPageView("topic(booknumber)")
fun! <SID>ManPageView(...)
"  let g:decho_hide         = 1 " Decho
"  call Dfunc("ManPageView() a:0=".a:0)
  set lz

  if a:0 == 0
   if exists("g:ManCurPosn") && has("mksession")
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn exists")
	call s:ManRestorePosn()
   else
    echomsg "***usage*** :Man topic  -or-  :Man topic nmbr"
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn doesn't exist")
   endif
"   call Dret("ManPageView")
   return

  elseif a:0 == 1
"   call Decho("ManPageView: a:0=".a:0." a:1<".a:1.">")
   if a:1 =~ "("
	" abc(3)
	let a1 = substitute(a:1,'[-+*/;,.:]\+$','','e')
	if a1 =~ '[,"]'
     let manpagetopic= substitute(a1,'[(,"].*$','','e')
     let manpagebook = ""
	else
     let manpagetopic= substitute(a1,'^\(.*\)(\d\+[A-Z]\=),\=','\1','e')
     let manpagebook = substitute(a1,'^.*(\(\d\+\)[A-Z]\=),\=','\1','e')
	endif
   else
    " abc
    let manpagetopic= a:1
    let manpagebook = ""
   endif

  else
   " 3 abc  -or-  abc 3
   if     a:1 =~ '^\d\+'
    let manpagebook = a:1
    let manpagetopic= a:2
   elseif a:2 =~ '^\d\+$'
    let manpagebook = a:2
    let manpagetopic= a:1
   else
	" default: topic book
    let manpagebook = a:2
    let manpagetopic= a:1
   endif
  endif
"  call Decho("manpagebook<".manpagebook."> manpagetopic<".manpagetopic.">")

  " This code decides on what window the manpage will be displayed
  if     g:manpageview_winopen == "only"
"   call Decho("only mode")
   silent! windo w
   if !exists("g:ManCurPosn") && has("mksession")
    call s:ManSavePosn()
   endif
   " Record current file/position/screen-position
   if &ft != "man"
    only!
   endif
   enew!
  elseif g:manpageview_winopen == "hsplit"
"   call Decho("hsplit mode")
   if &ft != "man"
    wincmd s
    enew!
    wincmd _
    3wincmd -
   else
    enew!
   endif
  elseif g:manpageview_winopen == "hsplit="
"   call Decho("hsplit= mode")
   if &ft != "man"
    wincmd s
   endif
   enew!
  elseif g:manpageview_winopen == "vsplit"
"   call Decho("vsplit mode")
   if &ft != "man"
    wincmd v
    enew!
    wincmd |
    20wincmd <
   else
    enew!
   endif
  elseif g:manpageview_winopen == "vsplit="
"   call Decho("vsplit= mode")
   if &ft != "man"
    wincmd v
   endif
   enew!
  elseif g:manpageview_winopen == "reuse"
   if &mod == 1
   	" file has been modified, would be lost if we re-used window.
	" Use hsplit instead.
    wincmd s
    enew!
    wincmd _
    3wincmd -
   elseif &ft != "man"
   	setlocal bh=hide
    enew!
   else
    enew!
   endif
  else
   echoerr "sorry, g:manpageview_winopen<".g:manpageview_winopen."> not supported"
"   call Dret("ManPageView : manpageview_winopen<".g:manpageview_winopen."> not supported")
   return
  endif
  " when this buffer is exited it will be wiped out
  setlocal bh=wipe
  let b:did_ftplugin= 2

  " special manpageview buffer maps
  nnoremap <buffer> <space>     <c-f>
  nnoremap <buffer> <c-]>       :call <SID>ManPageView(expand("<cword>"))<cr>

  " invoke the man command to get the manpage
  setlocal mod
"  call Decho("manpagebook<".manpagebook."> topic<".manpagetopic.">")
  if has("win32") && exists("g:manpageview_server") && exists("g:manpageview_user")
   exe "r!rsh g:manpageview_server -l g:manpageview_user man ".g:manpageview_options." ".manpagebook." ".manpagetopic
   silent! %s/.\b//ge
" elseif has("conceal")
"  exe "r!man ".g:manpageview_options." ".manpagebook." ".manpagetopic
  else
   exe "r!man ".g:manpageview_options." ".manpagebook." ".manpagetopic
   silent! %s/.\b//ge
  endif
  setlocal ft=man ro noma nomod nolist isk+=-,.,(,)
  set nolz
  1
  norm! 0
  if line("$") == 1 && col("$") == 1
   " looks like there's no help for this topic
   q
"   call Decho("***warning*** no manpage exists for <".manpagetopic."> book=".manpagebook)
   echoerr "***warning*** no manpage exists for <".manpagetopic.">"
  elseif manpagebook == ""
   exe "file ".'Manpageview['.manpagetopic.']'
  else
   exe "file ".'Manpageview['.manpagetopic.'('.manpagebook.')]'
  endif
"  call Dret("ManPageView")
endfun

" ---------------------------------------------------------------------

" ManRestorePosn:  uses g:ManCurPosn to restore file/position/screen-position
fun! <SID>ManRestorePosn()
  if exists("g:ManCurPosn")
"   call Decho("ManRestorePosn: g:ManCurPosn<".g:ManCurPosn.">")
   exe 'silent! source '.g:ManCurPosn
   unlet g:ManCurPosn
   cunmap q
  endif
endfun

" ---------------------------------------------------------------------

" ManSavePosn: saves current file, line, column, and screen position
fun! <SID>ManSavePosn()
"  call Decho("ManSavePosn")
  let g:ManCurPosn= tempname()
  let keep_ssop   = &ssop
  let &ssop       = 'winpos,buffers,slash,globals,resize,blank,folds,help,options,winsize'
  exe 'silent! mksession! '.g:ManCurPosn
  let &ssop       = keep_ssop
  cnoremap <silent> q call <SID>ManRestorePosn()<CR>
endfun

" ---------------------------------------------------------------------
" vim: ts=4
