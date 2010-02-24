" Vim Syntax File
" Name:      c.vim - extend standard syntax highlighting for c
" Type:      syntax file
" Version:   20040602
" Description:
"   This syntax file extends the standard syntax highlighting for c
"

" extend syntax-highlighting for "weave.w" only (not case-sensitive)

if tolower(expand("%:t"))=="weave.w"

  syntax region cwebFuncRegion	start=/@</ end=/@>/ contains=cwebIdentifier,cwebError
  syntax match cwebError	/@[^<>]/ contained
  syntax match cwebError	/@$/ contained
  syntax match cwebErrorOut	/@[^c=<]/
  syntax match cwebIdentifier	/|\i\+|/ contained
  syntax match cwebSpecial	/@[c=]/

  highlight link cwebFuncRegion	LineNr
  highlight link cwebIdentifier	Identifier
  highlight link cwebError	Error
  highlight link cwebErrorOut	Error
  highlight link cwebSpecial	Special
    
  set iskeyword=a-z,A-Z,48-57,_,.,-,>

endif
set iskeyword+=_

" vim: ts=8 sw=2
