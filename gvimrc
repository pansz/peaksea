" gvimrc for Poet's work
" See also: .vimrc

" Some settings will be reset after :source the .vimrc
" So, we have to put these settings in .gvimrc
"
" Also, in some cases the .vimrc will not be excused, those will also have to
" be set here.

set t_vb= mousehide cmdheight=1

if v:version >= 700
    set guioptions=Aige
else
    set guioptions=Aig
endif

let in_diff_mode = 0
if v:version >= 600
    windo let in_diff_mode = in_diff_mode + &l:diff
endif

" Font must be set in .gvimrc
if has("gui_win32")		" NT Windows

    " NT gui
    let Tlist_WinWidth = 29
    if v:version >= 600
        try
            language messages en
        finally
            set langmenu=none
        endtry
    endif

    if filereadable('c:\cygwin\bin\bash.exe')
        set shell=c:\cygwin\bin\bash
        " in NT, must use full POSIX path with BASH shell
        set grepprg=/usr/bin/grep\ -nH\ $*\ /dev/null
        set makeprg=/usr/bin/make
        set path=.,c:/cygwin/usr/include,,
        set cscopeprg=/bin/mlcscope
    endif

    let cvimsyn=$HOME.'\vimfiles\CVIMSYN'
    if v:version >= 600
        " h15 for 1024x768, h18 for 1280x1024
        set guifont=Lucida_Console:h16:cDEFAULT

        " h14 for 800x600 low-end CRT monitors.
        " set guifont=isi_oem:h14:cOEM
        " set guifont=isi_ansi:h14:cDEFAULT
        " set guifontwide=
        " set guifontwide=SimSun-18030,Arial_Unicode_MS
        nnoremap <Leader>fl :se gfn=Lucida_Console:h15:cDEFAULT<cr>
        nnoremap <Leader>fi :se gfn=isi_ansi:h14:cDEFAULT<cr>

        " In diff mode
        if in_diff_mode == 1
            set guifont=isi_ansi:h14:cDEFAULT
        endif

        if has("gui_win32")		" NT Windows
            nnoremap <silent> <Leader>cv :%s/“/『/eg<CR>:%s/‘/「/eg<CR>:%s/’/」/eg<CR>:%s/”/』/eg<CR>:%s/…/┅/eg<CR>:%s/—/─/eg<CR>:%s/–/－/eg<CR>
            nnoremap <silent> <Leader>cu :%s/磘/'t/eg<CR>:%s/磗/'s/eg<CR>
        endif

    else
        set guifont=Lucida_Console:h16
        nnoremap <Leader>fl :se gfn=Lucida_Console:h15<cr>
        nnoremap <Leader>fi :se gfn=isi_ansi:h14<cr>
    endif

elseif has("x11")		" X Window
    " X11 GUI
    let Tlist_WinWidth = 20
    let cvimsyn=$HOME.'/.vim/CVIMSYN'
    if filereadable('/bin/bash')
        set shell=/bin/bash
    elseif filereadable('/bin/ksh')
        set shell=/bin/ksh
    elseif filereadable('/bin/sh')
        set shell=/bin/sh
    endif
    " set guifontwide=-*-song\ ti-medium-r-*-*-16-*-*-*-*-*-*-*
    set guifont=DejaVu\ Sans\ Mono\ 16
    nunmap <Leader>fp
    set columns=999 lines=999
    nnoremap <silent> <Leader>fp :cope 1<CR><C-W>w:Tlist<CR>
    " make the Keypad work in Linux
    nmap <kEnter> <cr>
    nmap <kMinus> -
endif

unlet in_diff_mode

" noremap! <MiddleMouse> <Nop>
" noremap <MiddleMouse> <Nop>

" screen scroll speed is not allowed in text mode
"nmap <silent> <Down> gj
"nmap <silent> <Up> gk

" CTRL-A is Select all
" noremap <C-A> gggH<C-O>G
" inoremap <C-A> <C-O>gg<C-O>gH<C-O>G
" cnoremap <C-A> <C-C>gggH<C-O>G

