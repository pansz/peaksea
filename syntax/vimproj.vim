" Vim syntax file
" Language:	Vim Project
" Maintainer:	Pan Shizhu <dicpan@hotmail.com>
" Last Change:	14 July 2004
" Comments:	This is inspired from Aric Blumer's project.vim plugin 
"

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


syntax match projectDescriptionDir '^\s*.\{-}=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
syntax match projectDescription    '\<.\{-}='he=e-1,me=e-1         contained nextgroup=projectDirectory contains=projectWhiteError
syntax match projectDescription    '{\|}'
syntax match projectDirectory      '=\(\\ \|\f\|:\)\+'             contained
syntax match projectDirectory      '=".\{-}"'                      contained
syntax match projectScriptinout    '\<in\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
syntax match projectScriptinout    '\<out\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
syntax match projectComment        '#.*'
syntax match projectCD             '\<cd\s*=\s*\(\\ \|\f\|:\|"\)\+' contains=projectDescription,projectWhiteError
syntax match projectFilterEntry    '\<filter\s*=.*"'               contains=projectWhiteError,projectFilterError,projectFilter,projectFilterRegexp
syntax match projectFilter         '\<filter='he=e-1,me=e-1        contained nextgroup=projectFilterRegexp,projectFilterError,projectWhiteError
syntax match projectFlagsEntry     '\<flags\s*=\( \|[^ ]*\)'       contains=projectFlags,projectWhiteError
syntax match projectFlags          '\<flags'                       contained nextgroup=projectFlagsValues,projectWhiteError
syntax match projectFlagsValues    '=[^ ]* 'hs=s+1,me=e-1          contained contains=projectFlagsError
syntax match projectFlagsError     '[^rtTsSwl= ]\+'                contained
syntax match projectWhiteError     '=\s\+'hs=s+1                   contained
syntax match projectWhiteError     '\s\+='he=e-1                   contained
syntax match projectFilterError    '=[^"]'hs=s+1                   contained
syntax match projectFilterRegexp   '=".*"'hs=s+1                   contained
syntax match projectFoldText       '^[^=]\+{'

highlight def link projectDescription  Identifier
highlight def link projectScriptinout  PreProc
highlight def link projectFoldText     Special
highlight def link projectComment      Comment
highlight def link projectFilter       PreProc
highlight def link projectFlags        PreProc
highlight def link projectDirectory    Directory
highlight def link projectFilterRegexp String
highlight def link projectFlagsValues  Number
highlight def link projectWhiteError   Error
highlight def link projectFlagsError   Error
highlight def link projectFilterError  Error


" ProjFoldText()
"   The foldtext function for displaying just the description.
"   This function must be Global
function! ProjFoldText()
    let line=substitute(getline(v:foldstart),'^[ \t#]*\([^=]*\).*', '\1', '')
    let line=strpart('                                        ', 0, 
                \(v:foldlevel - 1)*&sw).substitute(line,'\s*{\+\s*', '', '')
    return line
endfunction


setlocal foldenable foldmethod=marker foldmarker={,} commentstring=%s 
setlocal foldcolumn=0 nonumber
setlocal foldtext=ProjFoldText() nobuflisted nowrap

let b:current_syntax = "vimproj"


" vim:nowrap:
