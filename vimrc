" Poet's .vimrc
" Last modified: 17 Jun 2006
" See also: .gvimrc

" A ruler to ensure at least 80 as width
" -------1---------2---------3---------4---------5---------6---------7---------8

" This must be first, because it changes other options as a side effect.
set nocompatible

" File encodings must be recognized first
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,euc-cn,cp936,gb18030,latin1
set background=dark
set noloadplugins

" These must set before menu.vim are sourced, so they appear here.
augroup vimrcEx
    autocmd!

    " When editing a file, always jump to the last known cursor position.
    autocmd BufReadPost *
	\ if line("'\"") > 0 && line("'\"") <= line("$") |
	\   execute "normal g`\"" |
	\ endif

    if has("gui_win32")		" NT Windows
        autocmd GUIEnter * :simalt ~x
    endif
    autocmd FilterWritePre * if &fdc != 0 | set fdc=0 | endif
    " autocmd BufNew * :set fileformat=unix
    " autocmd BufNewFile,BufRead *.out,*.aux	setf tex
    autocmd BufNewFile,BufRead *.erm		setf erm
    autocmd BufNewFile,BufRead *.cfg		setf wesnothcfg
augroup END

" Since the BufExplorer is loaded, disable this to improve performance.
let no_buffers_menu = 1

" Platform dependent settings
if !has("gui_running")
    if has("win32unix")		" Cygwin console
        let cvimsyn=$HOME.'/.vim/CVIMSYN'
        set shell=/bin/bash
        set grepprg=grep\ -nH\ $*\ /dev/null
        set cscopeprg=/bin/mlcscope

    elseif has("unix")		" Unix console
        let cvimsyn=$HOME.'/.vim/CVIMSYN'
        set path=.,,..,include,../include,../../include,/usr/include
        if filereadable('/bin/bash')
            set shell=/bin/bash
        elseif filereadable('/bin/sh')
            set shell=/bin/sh
        endif
    endif

    " Terminal configuration
    if &term == 'xterm'
        " Color XTerm is provided with all X distributions.
        " It has good mouse support with 256 color support
        set t_Co=256 
        " this works only for Konsole 2.0+, and now we use xterm
        " let &t_SI = "\<Esc>]50;CursorShape=1\x7"
        " let &t_EI = "\<Esc>]50;CursorShape=0\x7"

        if has('x11')
            set mouse=a
        endif

        " this seems no longer required
        if 0
            " Map <Pad5> to <Nop>
            map OE <Nop>
            map! OE <Nop>
            map OM <CR>
            " Map the shift-pad keys.
            map Ow <S-Home>
            map! Ow <S-Home>
            map Ox <S-Up>
            map! Ox <S-Up>
            map Oy <S-PageUp>
            map! Oy <S-PageUp>
            map Ot <S-Left>
            map! Ot <S-Left>
            map Ou <Nop>
            map! Ou <Nop>
            map Ov <S-Right>
            map! Ov <S-Right>
            map Oq <S-End>
            map! Oq <S-End>
            map Or <S-Down>
            map! Or <S-Down>
            map Os <S-PageDown>
            map! Os <S-PageDown>
            map [2~ <C-Insert>
            map! [2~ <C-Insert>
            map Op <S-Insert>
            map! Op <S-Insert>
            map On <S-Del>
            map! On <S-Del>
        endif

    elseif &term == 'screen'
        " screen terminal has wrong interpration of backspace
        " it need to be re-compiled for 256-color support
        " but it is better to leave it 16-color
        map  <backspace>
        map!  <backspace>
        map OM <CR>
        set t_Co=16
        set mouse=a
        set ttymouse=xterm2
    elseif &term == 'screen-256color'
        set t_Co=256
        set mouse=a
        set ttymouse=xterm2
    elseif &term == 'cygwin'
        " Truly crippled terminal, nothing to say, but it's the default.
        " Sometimes we have to use it
        " Map <Pad5> to <Nop>
        set t_Co=16
        map [G <Nop>
        map! [G <Nop> 
    elseif &term=='linux'
        set t_Co=8
    endif

endif

" Preference settings

set cpoptions=aABceFs formatoptions=cro2q backspace=indent,eol,start
set history=50 ruler showcmd incsearch hlsearch 
set selectmode= mousemodel=popup keymodel=startsel,stopsel
set selection=exclusive backspace=indent,eol,start whichwrap=b,s
set backupdir=~/.vimtmp backup visualbell fileformats=unix,mac,dos
set shiftwidth=4 tabstop=8 expandtab smarttab autoindent
set nolinebreak textwidth=78 helpheight=24 shellslash fileformat=unix
set winminheight=0 winwidth=1 t_vb= shortmess=filmnrxtToO nostartofline
set keywordprg= lazyredraw laststatus=0
set viminfo='1000,h,f1,\"500,%,n~/.viminfo tags=./tags,tags,../tags,../../tags,../../../tags
set cinoptions=>s,e0,n0,f0,{0,}0,^0,:0,=s,l1,g0,hs,ps,t0,+s,c3,C0,(2s,)20,
		\us,U0,w0,m0,j0,*30
set isprint=@,~-255 display=lastline nrformats=hex clipboard=autoselect
"set list lcs=tab:._,trail:_

if v:version >= 600
    set formatoptions+=cro2qmM1 winminwidth=0 cdpath=,.,~,.. virtualedit=block

    if has("multi_byte") && (v:version >= 602)
        set ambiwidth=double
    endif
    if has('folding')
        set foldlevelstart=99
    endif
endif
set cscopequickfix=s-,c-,d-,i-,t-,e-

" Functions

" ReMapppings

inoremap <silent> <tab> <c-v><tab>
inoremap <silent> <F6> <C-O><C-W>w
nnoremap <silent> <tab> <C-W>w
nnoremap <silent> <C-N> :cn<cr>
nnoremap <silent> <C-P> :cp<cr>

if has("cscope")
    " add any database in current directory
    set nocsverb
    if filereadable("cscope.out")
        cs add cscope.out
    elseif filereadable("../cscope.out")
        cs add ../cscope.out
    elseif filereadable("../../cscope.out")
        cs add ../../cscope.out
    elseif filereadable("../../../cscope.out")
        cs add ../../../cscope.out
    endif
    set csverb
    set csto=0
endif

noremap <silent> P P`[
noremap ; :
noremap - ;
noremap ' "
map  <cr>

" noremap <C-K> <C-W>W<C-W>_999<C-W>\|
" noremap <C-L> <C-W>w<C-W>_999<C-W>\|

" nnoremap <silent> <F1> :help index
" nnoremap <silent> <F2> :A<CR>
nnoremap <silent> <F3> :Explore<CR>
nnoremap <silent> <F4> :BufExplorer<CR>
nnoremap <silent> <F5> :TlistSync<CR>
" nnoremap <silent> <F6> <C-W>w
" nnoremap <F7> :tj 
" nnoremap <silent> <F6> <C-W>w<C-W>_999<C-W>\|
" nnoremap <silent> <F7> <C-W>W<C-W>_999<C-W>\|
" nnoremap <silent> <F8> <Plug>CalendarV:q!<CR>:Tlist<CR>
" <F9> is undefined here
" <F10> is reserved to activate the menu
" <F11> is system mapped to launch the bash shell
" nnoremap <silent> <F12> :Project<CR>

" My custom defined <Leader> mappings
" nmap <silent> <Leader>ca :TlistClose<cr><Plug>CalendarV
nmap <silent> <Leader>cc /\/\/<cr>lr*a <esc>$a */<esc>:noh<cr>
" nmap <silent> <Leader>ch :TlistClose<cr><Plug>CalendarH
nnoremap <silent> <Leader>cd :cd %:p:h<cr>:pwd<cr>
" nnoremap <silent> <Leader>cf :cf *.log<cr>
" nnoremap <silent> <Leader>cn Gk$<C-]>
" nnoremap <silent> <Leader>cp ggj$<C-]>
nnoremap <silent> <Leader>cm :%s///g
" vmap <silent> <Leader>cr <Plug>CRV_CRefVimVisual
" nmap <silent> <Leader>cr <Plug>CRV_CRefVimNormal
" nnoremap <silent> <Leader>gr :cd %:p:h<cr>:vimgrep <cword> *.cpp *.c *.h<cr>
" nnoremap <silent> <Leader>mp :Man <C-R><C-W><CR>

nnoremap <silent> <Leader>pt :ru syntax/hitest.vim<CR>
nnoremap <silent> <Leader>fp :cope 1<CR><C-W>w:Tlist<CR>

" nnoremap <silent> <Leader>ue :%!uuencode -m /dev/stdout<CR>
" nnoremap <silent> <Leader>ud :%!uudecode -o /dev/stdout<CR>
" vnoremap <silent> <Leader>ue !uuencode -m /dev/stdout<CR>
" vnoremap <silent> <Leader>ud !uudecode -o /dev/stdout<CR>

nnoremap <silent> <Leader>tl :Tlist<CR><C-W>w
nnoremap <silent> <Leader>te :tabedit <cfile>

nnoremap <silent> <Leader>vs :999vs<CR>

" Color switching is available
nnoremap <silent> <Leader>pc :let psc_style="cool"<CR>:set bg=dark<CR>
nnoremap <silent> <Leader>pw :let psc_style="warm"<CR>:set bg=light<CR>
nnoremap <silent> <Leader>vm :noautocmd vimgrep /\<<c-r><c-w>\>/j **/*.[ch]p\=p\=<cr>
vnoremap <Leader>vm "my:noautocmd vimgrep /<c-r>m/j **/*.[ch]p\=p\=<cr>
vnoremap <Leader>vp "my:noautocmd vimgrep '<c-r>m'j **/*.[ch]p\=p\=<cr>

" Garbage mappings just to disable the default
nmap <silent> <Leader>gbg1 <Plug>ManPageView
map <silent> <Leader>gbg2 <Plug>CRV_CRefVimAsk
map <silent> <Leader>gbg3 <Plug>CRV_CRefVimInvoke

" These stuffs enables <Ctrl-Insert> style shortcuts.
" Which resembles the old Borland IDE style.
" The Microsoft CUA style <C-C>, <C-V>, <C-X> is a very bad style for
" terminals, the <C-C> is always reserved, while <C-V> should be used for
" VISUAL BLOCK copy, so, simply abandon the habit of using <C-C> <C-V>!

vnoremap <S-Del> "+x
vnoremap <C-Insert> "+y

nnoremap <S-Insert>	"+gP
cnoremap <S-Insert>	<C-R>+

" Pasting blockwise and linewise selections is not possible in Insert and
" Visual mode without the +virtualedit feature.  They are pasted as if they
" were characterwise instead.
nnoremap <silent> <SID>Paste	"=@+.'xy'<CR>gPFx"_2x
imap <script> <S-Insert>	x<Esc><SID>Paste"_s
vmap <script> <S-Insert>	"-c<Esc>gix<Esc><SID>Paste"_x
nnoremap + <c-w>+


" Global variable defines
" the 'let' commands here implies g: as the scope

" for LPC syntax
if 0
    let lpc_syntax_for_c = 1
    let c_gnu = 0
endif

" for vimspell plugin
let spell_executable = "aspell"
let spell_language_list = "english"

" for latex suite
if 0
    let tex_indent_items = 1
    let tex_no_error = 1
    if has("gui_win32")
        let Tex_DefaultTargetFormat = 'pdf'
        let Tex_CompileRule_dvi = '/usr/bin/make dvi'
        let Tex_CompileRule_ps = '/usr/bin/make ps'
        let Tex_CompileRule_pdf = '/usr/bin/make'	" This allows make clean
        let Tex_ViewRule_dvi = 'c:/texlive/bin/win32/windvi'
        let Tex_ViewRule_ps = 'c:/progra~1/ghostgum/gsview/gsview32'
        let Tex_ViewRule_pdf = 'c:/progra~1/ghostgum/gsview/gsview32'
    elseif has("win32unix") || has("unix") || has ("x11")
        let Tex_DefaultTargetFormat = 'ps'
        let Tex_CompileRule_dvi = 'make dvi'
        let Tex_CompileRule_ps = 'make'
        let Tex_CompileRule_pdf = 'make pdf'
        let Tex_ViewRule_dvi = 'xdvi'
        let Tex_ViewRule_ps = 'ghostview'
        let Tex_ViewRule_pdf = 'xpdf'
    endif
    if has("win32unix")
        let Tex_DefaultTargetFormat = 'pdf'
        let Tex_CompileRule_ps = 'make ps'
        let Tex_CompileRule_pdf = 'make'
    endif
endif

" for taglist plugin
let Tlist_Ctags_Cmd = '/usr/bin/ctags'
let Tlist_Inc_Winwidth = 0
let Tlist_Compact_Format = 1
if !has("gui_running")
    if has("X11")
        " Unix console
        let Tlist_WinWidth = 23
    else
        " cygwin DOS console
        let Tlist_WinWidth = 21
    endif
endif
let Tlist_Enable_Fold_Column = 0
let Tlist_Sort_Type = 'name'
let Tlist_File_Fold_Auto_Close = 0
let Tlist_Display_Prototype = 0
let Tlist_Exit_OnlyWindow = 1
let Tlist_Show_One_File = 1
let Tlist_Use_Right_Window = 0

" for project plugin
let proj_flags = 'iLsc'

" for manpageview plugin
let manpageview_winopen = 'reuse'

" for sh syntax
let is_bash = 1

" only enable needed plugins
runtime plugin/gzip.vim
runtime plugin/netrwPlugin.vim
runtime plugin/bufexplorer.vim
runtime plugin/taglist.vim
" runtime plugin/tohtml.vim
" runtime plugin/crefvim.vim
runtime macros/matchit.vim

" vimim only works for vim7
if v:version >= 700
    let g:vimim_shuangpin='abc'
    let g:vimim_cursor_color='#f0c0f0'
    let g:vimim_chinese_input_mode='static'
    let g:vimim_custom_color=0
    set pumheight=10
    if has("win32") || has("win32unix")
        let g:vimim_cloud_mycloud="dll:".$HOME."/vimfiles/plugin/libvimim.dll:172.16.55.240"
    else
        let g:vimim_cloud_mycloud="dll:".$HOME."/.vim/plugin/libvimim.so:172.16.55.240"
    endif
    "let g:vimim_cloud_mycloud="app:".$HOME."/src/misc/myim/client/mycloud"
    "let g:vimim_cloud_mycloud="http://127.0.0.1:8080/abc/"
    "let g:vimim_cloud_mycloud="http://pim-cloud.appspot.com/qp/"
    if has("gui_win32")		" NT Windows
        runtime plugin/vimim.vim
    else
        if filereadable($HOME."/.vim/plugin/vimimsvn.vim")
            runtime plugin/vimimsvn.vim
        else
            runtime plugin/vimim.vim
        endif
    endif
endif

" disable autoload of ruby,perl,python in vim.vim
let g:vimsyn_embed=0

" Before enabling the color scheme, make sure these options are on
if v:version >= 600
    filetype plugin indent on
else
    filetype on
endif
if !exists("syntax_on")
    syntax on
endif

" Last but not least, enable my color scheme!
if v:version >= 600
    execute "colorscheme peaksea"
endif

" match NonText /\%>80v./

" A statusbar function, that provides a visual scrollbar (courtesy of A.Politz)
func! MySTL()
    let stl = '%f %{(&fenc==&enc?"":&fenc).((exists("+bomb") && &bomb)?",B":"")}%M%R%H%W%Y %c%V,%l/%L %='
    let barWidth = &columns - 80 " <-- wild guess
    let barWidth = barWidth < 3 ? 3 : barWidth

    if line('$') > 1
        let progress = (line('.')-1) * (barWidth-1) / (line('$')-1)
        let bar = '%P%<[%'.barWidth.'.'.barWidth.'('
                \.repeat('-',progress ).'%#PmenuThumb#O%0*'
                \.repeat('-',barWidth - progress - 1).'%)]'
    else
        let bar = '%P%<[%'.barWidth.'.'.barWidth.'('.repeat('-',barWidth).'%)]'
    endif

    return stl.bar
endfun

set stl=%!IMName().MySTL()
"set stl=%!MySTL()

autocmd BufNewFile *.py 0r $HOME/.vim/temp/template.py

" vim:tw=0:sw=4:nowrap:nolbr:
