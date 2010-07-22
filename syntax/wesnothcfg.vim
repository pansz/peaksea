" Vim syntax file
" Language:	Wesnoth CFG files (a.k.a WML files)
" Maintainer:	Pan, Shi Zhu (see the entry in vim.sf.net for details)
" Last change:	2010 Jul 19

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
    syntax clear
elseif exists ("b:current_syntax")
    finish
endif

" case off (is this desired for Wesnoth Markup Language?)
syn case ignore

" Param
syn match  wmlStatement	"^\s*[a-zA-Z0-9_,]\+="
syn match  wmlParam	"\w\+=" contained
syn match  wmlKeyword	"\$\w\+"
syn match  wmlSpecial	"\$(\w\+)"
syn match  wmlUpper	"\^" contained
syn match  wmlHeader	"<\w\+>" contained
syn match  wmlHeader	"</\w\+>" contained
syn match  wmlPlus	"+" contained
syn match  wmlSymbol	"/" contained
"syn match  wmlSymbol	'"' contained

" Sections
syn match wmlFunction	"^\s*\[[+/]\=\w\+\]" contains=wmlPlus,wmlSymbol
syn match wmlSpecial	"{[a-zA-Z0-9_/.~]\+}"
syn region wmlMacro	start="{[a-zA-Z0-9_/]\+ " end="}" contains=wmlSpecial,wmlParam,wmlFunction,wmlString
syn match  wmlString	"\".*\"" contained

" Comments (Everything before '#' or '//' or ';')
syn match  wmlComment	"#.*"
syn match  wmlComment	"#\[.*\]"

" PreProc
syn match  wmlPreProc	"#define .*"
syn match  wmlPreProc	"#undef .*"
syn match  wmlPreProc	"#enddef"
syn match  wmlPreProc	"#ifdef .*"
syn match  wmlPreProc	"#else"
syn match  wmlPreProc	"#endif"
syn match  wmlPreProc	"#ifhave .*"
syn match  wmlPreProc	"#ifnhave .*"
syn match  wmlPreProc	"#textdomain .*"
syn match  wmlPreProc	"# wmllint: .*"

" String
syn region wmlRegion	start=/"/ end=/"/ contains=wmlUpper,wmlPlus,wmlSymbol,wmlHeader,wmlParam,wmlKeyword

" Define the default hightlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_cfg_syn_inits")
    if version < 508
	let did_cfg_syn_inits = 1
	command -nargs=+ HiLink hi link <args>
    else
	command -nargs=+ HiLink hi def link <args>
    endif

    HiLink wmlComment		Comment
    HiLink wmlTodo		Todo
    HiLink wmlKeyword		Keyword
    HiLink wmlString		String
    HiLink wmlConstant		Constant
    HiLink wmlStatement	Type
    HiLink wmlType		Statement
    HiLink wmlMacro		Keyword
    HiLink wmlFunction		Function
    HiLink wmlPreProc		PreProc
    HiLink wmlSymbol		Constant
    HiLink wmlHeader		Constant
    HiLink wmlParam		Constant
    HiLink wmlPlus		Constant
    HiLink wmlUpper		Constant
    HiLink wmlIgnore		Ignore
    HiLink wmlSpecial		Special
    HiLink wmlLineNr		LineNr
    HiLink wmlNormal		Normal
    HiLink wmlIgnore		Ignore
    HiLink wmlMoreMsg		MoreMsg

    delcommand HiLink
endif
let b:current_syntax = "cfg"
" vim:ts=8
