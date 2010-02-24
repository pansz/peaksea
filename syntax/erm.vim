" Vim syntax file
" Language:	ERM (Event Related Model for SoD 3.1 and above)
" Maintainer:	Pan, Shi Zhu (See the following URL for contact)
" URL:		n/a now, prepareing to upload on vim.sf.net
" Last Change:	5 Jan 2007

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

" important settings to ensure, uppercase letters should not be considered
" as any part of identifier.
setlocal iskeyword=a-z,48-57,-

" Identifiers
syn match	ermIdentifier	contained "z-\d\{1,2}"	" z-1 z-10
syn match	ermIdentifier	contained "z\d\{1,8}"	" z1-z10000000
syn match	ermIdentifier	contained "y-\=\d\{1,3}"	" y1-y100, y-1 y-100
syn match	ermIdentifier	contained "x\d\{1,2}"	" x1-x16
syn match	ermIdentifier	contained "w\d\{1,3}"	" w1-w100, w-1 w-100
syn match	ermIdentifier	contained "v\d\{1,5}"	" v1-v10000
syn match	ermIdentifier	contained "\<c\>"	" c the current day
syn match	ermIdentifier	contained "e-\=\d\{1,3}"	" e1-e100, e-1 e-100
syn keyword	ermQuickVar	contained f g h i j k l m n o p q r s t
syn match	ermMacroRef	contained "\$\i\{-1,}\$"
syn match	ermMacroDef	contained "@\i\{-1,}@"

" string formats
syn match	ermStringFormat	contained "%Z"
syn match	ermStringFormat	contained "%Y"
syn match	ermStringFormat	contained "%X"
syn match	ermStringFormat	contained "%W"
syn match	ermStringFormat	contained "%E"
syn match	ermStringFormat	contained "%\$\i\{-1,}\$"

" Symbols
syn match	ermSymbol	contained "&"
syn match	ermSymbol	contained "|"
syn match	ermDelimeter	contained "/"
syn match	ermDivColon	contained ":"	" highlighted just to distinguish FirstColon
syn match	ermEOS		contained ";"	" End of Statement
syn match	ermModifier	contained "?"
syn match	ermModifier	contained "\<d"

" top-level
syn match	ermPreProc	"^ZVSE"
syn match	ermFileInfo	"^ERMS_\_.\{-}=\{-}$"
syn match	ermWarning	"^_WARNING_\_.\{-}=\{-}$"
syn match	ermSplitter	"-\{3,}"

" sub-elements
syn match	ermTodo		contained "\WTODO"ms=s+1
syn match	ermTodo		contained "\WFIXME"ms=s+1
syn match	ermTodo		contained "\WXXX"ms=s+1
syn cluster	ermInnerRef	contains=ermTodo,ermIdentifier,ermMacroRef
syn region	ermPostComment	oneline start="\[" end="\]" contains=@ermInnerRef
syn match	ermLineComment	"\s*\*.*$" contains=@ermInnerRef
syn match	ermLineComment	"\s*//.*$" contains=@ermInnerRef
syn match	ermLineComment	"\s*;.*$" contains=@ermInnerRef
syn cluster	ermObjects	contains=ermIdentifier,ermMacroRef,ermQuickVar,ermSymbol,ermDelimeter
syn cluster	ermCondition	contains=@ermObjects,ermSymbol
syn match	ermString	contained "\^\_[^;^]\{-}\^"
syn region	ermParameters	matchgroup=ermFirstColon contained start=":" end=";" contains=@ermObjects,ermDivColon,ermString,ermModifier,ermMacroDef,ermEOS

" make sure that long strings are displayed correctly
syn sync minlines=30

" for Vim 7: define clusters for spell check
syn cluster	Spell		contains=ermPostComment,ermLineComment

" main parts
syn match	ermReceiver	"!!\u\u\_.\{-};" contains=@ermCondition,ermParameters
syn match	ermDirective	"!#\u\u\_.\{-};" contains=@ermCondition,ermParameters
syn match	ermPostTrigger	"!\$\u\u.\{-};" contains=@ermCondition,ermEOS
syn match	ermPreTrigger	"!?\u\u.\{-};" contains=@ermCondition,ermEOS
syn region	ermDisabledCode	start="\s*\*!\u\u" skip="\^\_[^;^]\{-}\^" end=";.*$"
syn region	ermDisabledCode	start="\s*\*#\u\u" skip="\^\_[^;^]\{-}\^" end=";.*$"
syn region	ermDisabledCode	start="\s*\~" skip="\^\_[^;^]\{-}\^" end=";.*$"

" define comments header
setlocal comments=s0:**,mb:**,e:***

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link ermComment		Comment
hi def link ermTodo		Todo
hi def link ermKeyword		Keyword
hi def link ermString		String
hi def link ermConstant		Constant
hi def link ermStatement	Type
hi def link ermType		Statement
hi def link ermFunction		Function
hi def link ermPreProc		PreProc
hi def link ermIgnore		Ignore
hi def link ermSpecial		Special
hi def link ermLineNr		LineNr
hi def link ermNormal		Normal
hi def link ermIgnore		Ignore
hi def link ermMoreMsg		MoreMsg

hi def link ermLineComment	ermComment
hi def link ermPostComment	ermComment
hi def link ermIdentifier	ermConstant
hi def link ermReceiver		ermStatement
hi def link ermPreTrigger	ermFunction
hi def link ermPostTrigger	ermFunction
hi def link ermDirective	ermPreProc
hi def link ermDisabledCode	ermLineNr
hi def link ermFileInfo		ermLineNr
hi def link ermWarning		ermIgnore
hi def link ermDelimeter	ermSpecial
hi def link ermSymbol		ermSpecial
hi def link ermDivColon		ermSpecial
hi def link ermFirstColon	ermMoreMsg
hi def link ermStringFormat	ermLineNr
hi def link ermSplitter		ermPreProc
hi def link ermQuickVar		ermConstant

hi def link ermEOS		ermMoreMsg
" Ctrl-M is required to mark the end of the ERM script
hi def link ermEOF		ermSpecial
match	ermEOF		/\%x0d/

hi def link ermMacro		ermIdentifier
hi def link ermModifier		ermPreProc
hi def link ermParameters	ermNormal
hi def link ermMacroDef		ermMacro
hi def link ermMacroRef		ermMacro

let b:current_syntax = "erm"

" vim: ts=8 sw=2
