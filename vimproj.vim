"
" File:        project.vim
" Last Change: 14 July 2004 
" Version:     pansz special
"
" See documentation in accompanying help file

if exists('loaded_project') || &cp
  finish
endif
let loaded_project=1

let s:defname = '.vimprojects'

if !exists('g:proj_flags') | let g:proj_flags = 'is' | endif

    " s:sort_r(start, end) <<<
    " Sort lines.  sort_r() is called recursively.
    "  from ":help eval-examples" by Robert Webb, slightly modified
    function! s:sort_r(start, end)
        if (a:start >= a:end)
            return
        endif
        let partition = a:start - 1
        let middle = partition
        let partStr = getline((a:start + a:end) / 2)
        let i = a:start
        while i <= a:end
            let str = getline(i)
            if str < partStr
                let result = -1
            elseif str > partStr
                let result = 1
            else
                let result = 0
            endif
            if (result <= 0)
                let partition = partition + 1
                if (result == 0)
                    let middle = partition
                endif
                if (i != partition)
                    let str2 = getline(partition)
                    call setline(i, str2)
                    call setline(partition, str)
                endif
            endif
            let i = i + 1
        endwhile
        if (middle != partition)
            let str = getline(middle)
            let str2 = getline(partition)
            call setline(middle, str2)
            call setline(partition, str)
        endif
        call s:sort_r(a:start, partition - 1)
        call s:sort_r(partition + 1, a:end)
    endfunc ">>>
    " s:is_absolute_path(path) <<<
    "   Returns true if filename has an absolute path.
    function! s:is_absolute_path(path)
        if a:path =~ '^ftp:' || a:path =~ '^rcp:' || a:path =~ '^scp:' || a:path =~ '^http:'
            return 2
        endif
        if a:path =~ '\$'
            let path=expand(a:path) " Expand any environment variables that might be in the path
        else
            let path=a:path
        endif
        if path[0] == '/' || path[0] == '~' || path[0] == '\\' || path[1] == ':'
            return 1
        endif
        return 0
    endfunction " >>>
    " s:construct_directives_r(lineno) <<<
    "   Construct the inherited directives
    function! s:construct_directives_r(lineno)
        let lineno=s:find_fold_top(a:lineno)
        let foldlineno = lineno
        let foldlev=foldlevel(lineno)
        let parent_infoline = ''
        if foldlev > 1
            while foldlevel(lineno) >= foldlev " Go to parent fold
                if lineno < 1
                    echoerr 'Some kind of fold error.  Check your syntax.'
                    return
                endif
                let lineno = lineno - 1
            endwhile
            let parent_infoline = s:construct_directives_r(lineno)
        endif
        let parent_home = s:get_home(parent_infoline, '')
        let parent_c_d = s:get_cd(parent_infoline, parent_home)
        let parent_scriptin = s:get_script_in(parent_infoline, parent_home)
        let parent_scriptout = s:get_script_out(parent_infoline, parent_home)
        let parent_filter = s:get_filter(parent_infoline, '*')
        let infoline = getline(foldlineno)
        " Extract the home directory of this fold
        let home=s:get_home(infoline, parent_home)
        if home != ''
            if (foldlevel(foldlineno) == 1) && !s:is_absolute_path(home)
                call confirm('Outermost Project Fold must have absolute path!  Or perhaps the path does not exist.', "&OK", 1)
                let home = '~'  " Some 'reasonable' value
            endif
        endif
        " Extract any CD information
        let c_d = s:get_cd(infoline, home)
        if c_d != ''
            if (foldlevel(foldlineno) == 1) && !s:is_absolute_path(c_d)
                call confirm('Outermost Project Fold must have absolute CD path!  Or perhaps the path does not exist.', "&OK", 1)
                let c_d = '.'  " Some 'reasonable' value
            endif
        else
            let c_d=parent_c_d
        endif
        " Extract scriptin
        let scriptin = s:get_script_in(infoline, home)
        if scriptin == ''
            let scriptin = parent_scriptin
        endif
        " Extract scriptout
        let scriptout = s:get_script_out(infoline, home)
        if scriptout == ''
            let scriptout = parent_scriptout
        endif
        " Extract filter
        let filter = s:get_filter(infoline, parent_filter)
        if filter == '' | let filter = parent_filter | endif
        return s:construct_info(home, c_d, scriptin, scriptout, '', filter)
    endfunction ">>>
    " s:construct_info(home, c_d, scriptin, scriptout, flags, filter) <<<
    function! s:construct_info(home, c_d, scriptin, scriptout, flags, filter)
        let retval='Directory='.a:home
        if a:c_d[0] != ''
            let retval=retval.' cd='.a:c_d
        endif
        if a:scriptin[0] != ''
            let retval=retval.' in='.a:scriptin
        endif
        if a:scriptout[0] != ''
            let retval=retval.' out='.a:scriptout
        endif
        if a:filter[0] != ''
            let retval=retval.' filter="'.a:filter.'"'
        endif
        return retval
    endfunction ">>>
    " s:open_entry(line, precmd, editcmd) <<<
    "   Get the filename under the cursor, and open a window with it.
    function! s:open_entry(line, precmd, editcmd, dir)
        silent exec a:precmd
        if (a:editcmd[0] != '')
            if a:dir
                let fname='.'
            else
                if (foldlevel(a:line) == 0) && (a:editcmd[0] != '')
                    return 0                    " If we're outside a fold, do nothing
                endif
                let fname=substitute(getline(a:line), '\s*#.*', '', '') " Get rid of comments and whitespace before comment
                let fname=substitute(fname, '^\s*\(.*\)', '\1', '') " Get rid of leading whitespace
                if strlen(fname) == 0
                    return 0                    " The line is blank. Do nothing.
                endif
            endif
        else
            let fname='.'
        endif
        let infoline = s:construct_directives_r(a:line)
        let retval=s:open_entry_inner(a:line, infoline, fname, a:editcmd)
        call s:display_info()
        return retval
    endfunction
    ">>>
    " s:open_entry_inner(line, infoline, precmd, editcmd) <<<
    "   Get the filename under the cursor, and open a window with it.
    function! s:open_entry_inner(line, infoline, fname, editcmd)
        let fname=escape(a:fname, ' ')
        let home=s:get_home(a:infoline, '').'/'
        if home=='/'
            echoerr 'Project structure error. Check your syntax.'
            return
        endif
        "Save the cd command
        let cd_cmd = b:proj_cd_cmd
        if a:editcmd[0] != '' " If editcmd is '', then just set up the environment in the Project Window
            " If it is an absolute path, don't prepend home
            if !s:is_absolute_path(fname)
                let fname=home.fname
            endif

            if &modified
                new
            endif
            " The file is loaded here!
            if s:is_absolute_path(fname) == 2
                exec a:editcmd.' '.fname
            else
                silent exec 'silent '.a:editcmd.' '.fname
            endif
        else " only happens in the Project File
            exec 'au! BufEnter,BufLeave '.expand('%:p')
        endif
        " Extract any CD information
        let c_d = s:get_cd(a:infoline, home)
        if c_d != '' && (s:is_absolute_path(home) != 2)
            if match(g:proj_flags, '\CL') != -1
                call s:setup_auto_command(c_d)
            endif
            if !isdirectory(glob(c_d))
                call confirm("From this fold's entry,\ncd=".'"'.c_d.'" is not a valid directory.', "&OK", 1)
            else
                silent exec cd_cmd.' '.c_d
            endif
        endif
        " Extract any scriptin information
        let scriptin = s:get_script_in(a:infoline, home)
        if scriptin != ''
            if !filereadable(glob(scriptin))
                call confirm('"'.scriptin.'" not found. Ignoring.', "&OK", 1)
            else
                call s:setup_script_auto_cmd('BufEnter', scriptin)
                exec 'source '.scriptin
            endif
        endif
        let scriptout = s:get_script_out(a:infoline, home)
        if scriptout != ''
            if !filereadable(glob(scriptout))
                call confirm('"'.scriptout.'" not found. Ignoring.', "&OK", 1)
            else
                call s:setup_script_auto_cmd('BufLeave', scriptout)
            endif
        endif
        return 1
    endfunction
    ">>>
    " s:fold_or_open_entry(cmd0, cmd1) <<<
    "   Used for double clicking. If the mouse is on a fold, open/close it. If
    "   not, try to open the file.
    function! s:fold_or_open_entry(cmd0, cmd1)
        if getline('.')=~'{\|}' || foldclosed('.') != -1
            normal! za
        else
            call s:open_entry(line('.'), a:cmd0, a:cmd1, 0)
        endif
    endfunction ">>>
    " s:vim_dir_listing(filter, padding, separator, filevariable, filecount, dirvariable, dircount) <<<
    function! s:vim_dir_listing(filter, padding, separator, filevariable, filecount, dirvariable, dircount)
        let end = 0
        let files=''
        let filter = a:filter
        " Chop up the filter
        "   Apparently glob() cannot take something like this: glob('*.c *.h')
        let while_var = 1
        while while_var
            let end = stridx(filter, ' ')
            if end == -1
                let end = strlen(filter)
                let while_var = 0
            endif
            let single=glob(strpart(filter, 0, end))
            if strlen(single) != 0
                let files = files.single."\010"
            endif
            let filter = strpart(filter, end + 1)
        endwhile
        " files now contains a list of everything in the directory. We need to
        " weed out the directories.
        let fnames=files
        let {a:filevariable}=''
        let {a:dirvariable}=''
        let {a:filecount}=0
        let {a:dircount}=0
        while strlen(fnames) > 0
            let fname = substitute(fnames,  '\(\(\f\|[ :]\)*\).*', '\1', '')
            let fnames = substitute(fnames, '\(\f\|[ :]\)*.\(.*\)', '\2', '')
            if isdirectory(glob(fname))
                let {a:dirvariable}={a:dirvariable}.a:padding.fname.a:separator
                let {a:dircount}={a:dircount} + 1
            else
                let {a:filevariable}={a:filevariable}.a:padding.fname.a:separator
                let {a:filecount}={a:filecount} + 1
            endif
        endwhile
    endfunction ">>>
    " s:generate_entry(recursive, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev, sort) <<<
    function! s:generate_entry(recursive, line, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev, sort)
        let line=a:line
        if a:dir =~ '\\ '
            let dir='"'.substitute(a:dir, '\\ ', ' ', 'g').'"'
        else
            let dir=a:dir
        endif
        let spaces=strpart('                                                             ', 0, a:foldlev * &sw)
        let c_d=(strlen(a:c_d) > 0) ? 'cd='.a:c_d.' ' : ''
        let c_d=(strlen(a:filter_directive) > 0) ? c_d.'filter="'.a:filter_directive.'" ': c_d
        call append(line, spaces.'}')
        call append(line, spaces.a:name.'='.dir.' '.c_d.'{')
        if a:recursive
            exec 'cd '.a:absolute_dir
            call s:vim_dir_listing("*", '', "\010", 'b:files', 'b:filecount', 'b:dirs', 'b:dircount')
            cd -
            let dirs=b:dirs
            let dcount=b:dircount
            unlet b:files b:filecount b:dirs b:dircount
            while dcount > 0
                let dname = substitute(dirs,  '\(\( \|\f\|:\)*\).*', '\1', '')
                let edname = escape(dname, ' ')
                let dirs = substitute(dirs, '\( \|\f\|:\)*.\(.*\)', '\2', '')
                let line=s:generate_entry(1, line + 1, dname, a:absolute_dir.'/'.edname, edname, '', '', a:filter, a:foldlev+1, a:sort)
                let dcount=dcount-1
            endwhile
        endif
        return line+1
    endfunction " >>>
    " s:do_entry_from_dir(line, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev, sort) <<<
    "   Generate the fold from the directory hierarchy (if recursive), then
    "   fill it in with refresh_entries_from_dir()
    function! s:do_entry_from_dir(recursive, line, name, absolute_dir, dir, c_d, filter_directive, filter, foldlev, sort)
        call s:generate_entry(a:recursive, a:line, a:name, escape(a:absolute_dir, ' '), escape(a:dir, ' '), escape(a:c_d, ' '), a:filter_directive, a:filter, a:foldlev, a:sort)
        normal! j
        call s:refresh_entries_from_dir(1)
    endfunction ">>>
    " s:create_entries_from_dir(recursive) <<<
    "   Prompts user for information and then calls s:do_entry_from_dir()
    function! s:create_entries_from_dir(recursive)
        " Save a mark for the current cursor position
        normal! mk
        let line=line('.')
        let name = inputdialog('Enter the Name of the Entry: ')
        if strlen(name) == 0
            return
        endif
        let foldlev=foldlevel(line)
        if (foldclosed(line) != -1) || (getline(line) =~ '}')
            let foldlev=foldlev - 1
        endif
        let absolute = (foldlev <= 0)?'Absolute ': ''
        let home=''
        let filter='*'
        if (match(g:proj_flags, '\Cb') != -1) && has('browse')
            " Note that browse() is inconsistent: On Win32 you can't select a
            " directory, and it gives you a relative path.
            let dir = browse(0, 'Enter the '.absolute.'Directory to Load: ', '', '')
            let dir = fnamemodify(dir, ':p')
        else
            let dir = inputdialog('Enter the '.absolute.'Directory to Load: ', '')
        endif
        if (dir[strlen(dir)-1] == '/') || (dir[strlen(dir)-1] == '\\')
            let dir=strpart(dir, 0, strlen(dir)-1) " Remove trailing / or \
        endif
        let dir = substitute(dir, '^\~', $HOME, 'g')
        if (foldlev > 0)
            let parent_directive=s:construct_directives_r(line)
            let filter = s:get_filter(parent_directive, '*')
            let home=s:get_home(parent_directive, '')
            if home[strlen(home)-1] != '/' && home[strlen(home)-1] != '\\'
                let home=home.'/'
            endif
            unlet parent_directive
            if s:is_absolute_path(dir)
                " It is not a relative path  Try to make it relative
                let hend=matchend(dir, '\C'.glob(home))
                if hend != -1
                    let dir=strpart(dir, hend)          " The directory can be a relative path
                else
                    let home=""
                endif
            endif
        endif
        if strlen(home.dir) == 0
            return
        endif
        if !isdirectory(home.dir)
            if has("unix")
                silent exec '!mkdir '.home.dir.' > /dev/null'
            else
                call confirm('"'.home.dir.'" is not a valid directory.', "&OK", 1)
                return
            endif
        endif
        let c_d = inputdialog('Enter the CD parameter: ', '')
        let filter_directive = inputdialog('Enter the File Filter: ', '')
        if strlen(filter_directive) != 0
            let filter = filter_directive
        endif
        " If I'm on a closed fold, go to the bottom of it
        if foldclosedend(line) != -1
            let line = foldclosedend(line)
        endif
        let foldlev = foldlevel(line)
        " If we're at the end of a fold . . .
        if getline(line) =~ '}'
            let foldlev = foldlev - 1           " . . . decrease the indentation by 1.
        endif
        " Do the work
        call s:do_entry_from_dir(a:recursive, line, name, home.dir, dir, c_d, filter_directive, filter, foldlev, 0)
        " Restore the cursor position
        normal! `k
    endfunction ">>>
    " s:refresh_entries_from_dir(recursive) <<<
    "   Finds metadata at the top of the fold, and then replaces all files
    "   with the contents of the directory.  Works recursively if recursive is 1.
    function! s:refresh_entries_from_dir(recursive)
        if foldlevel('.') == 0
            echo 'Nothing to refresh.'
            return
        endif
        " Open the fold.
        if getline('.') =~ '}'
            normal! zo[z
        else
            normal! zo]z[z
        endif
        let just_a_fold=0
        let infoline = s:construct_directives_r(line('.'))
        let immediate_infoline = getline('.')
        if strlen(substitute(immediate_infoline, '[^=]*=\(\(\f\|:\|\\ \)*\).*', '\1', '')) == strlen(immediate_infoline)
            let just_a_fold = 1
        endif
        " Extract the home directory of the fold
        let home = s:get_home(infoline, '')
        if home == ''
            " No Match.  This means that this is just a label with no
            " directory entry.
            if a:recursive == 0
                return          " We're done--nothing to do
            endif
            " Mark that it is just a fold, so later we don't delete filenames
            " that aren't there.
            let just_a_fold = 1
        endif
        if just_a_fold == 0
            " Extract the filter between quotes (we don't care what CD is).
            let filter = s:get_filter(infoline, '*')
            " Extract the description (name) of the fold
            let name = substitute(infoline, '^[#\t ]*\([^=]*\)=.*', '\1', '')
            if strlen(name) == strlen(infoline)
                return                  " If there's no name, we're done.
            endif
            if (home == '') || (name == '')
                return
            endif
            " Extract the flags
            let flags = s:get_flags(immediate_infoline)
            let sort = (match(g:proj_flags, '\CS') != -1)
            if flags != ''
                if match(flags, '\Cr') != -1
                    " If the flags do not contain r (refresh), then treat it just
                    " like a fold
                    let just_a_fold = 1
                endif
                if match(flags, '\CS') != -1
                    let sort = 1
                endif
                if match(flags, '\Cs') != -1
                    let sort = 0
                endif
            else
                let flags=''
            endif
        endif
        " Move to the first non-fold boundary line
        normal! j
        " Delete filenames until we reach the end of the fold
        while getline('.') !~ '}'
            if line('.') == line('$')
                break
            endif
            if getline('.') !~ '{'
                " We haven't reached a sub-fold, so delete what's there.
                if (just_a_fold == 0) && (getline('.') !~ '^\s*#') && (getline('.') !~ '#.*keep')
                    d _
                else
                    " Skip lines only in a fold and comment lines
                    normal! j
                endif
            else
                " We have reached a sub-fold. If we're doing recursive, then
                " call this function again. If not, find the end of the fold.
                if a:recursive == 1
                    call s:refresh_entries_from_dir(1)
                    normal! ]zj
                else
                    if foldclosed('.') == -1
                        normal! zc
                    endif
                    normal! j
                endif
            endif
        endwhile
        if just_a_fold == 0
            " We're not just in a fold, and we have deleted all the filenames.
            " Now it is time to regenerate what is in the directory.
            if !isdirectory(glob(home))
                call confirm('"'.home.'" is not a valid directory.', "&OK", 1)
            else
                let foldlev=foldlevel('.')
                " T flag.  Thanks Tomas Z.
                if (match(flags, '\Ct') != -1) || ((match(g:proj_flags, '\CT') == -1) && (match(flags, '\CT') == -1))
                    " Go to the top of the fold (force other folds to the
                    " bottom)
                    normal! [z
                    normal! j
                    " Skip any comments
                    while getline('.') =~ '^\s*#'
                        normal! j
                    endwhile
                endif
                normal! k
                let cwd=getcwd()
                let spaces=strpart('                                               ', 0, foldlev * &sw)
                exec 'cd '.home
                if match(g:proj_flags, '\Ci') != -1
                    echon home."\r"
                endif
                call s:vim_dir_listing(filter, spaces, "\n", 'b:files', 'b:filecount', 'b:dirs', 'b:dircount')
                if b:filecount > 0
                    silent! put =b:files
                    if sort
                        call s:sort_r(line('.'), line('.') + b:filecount - 1)
                    endif
                else
                    normal! j
                endif
                unlet b:files b:filecount b:dirs b:dircount
                exec 'cd '.cwd
            endif
        endif
        " Go to the top of the refreshed fold.
        normal! [z
    endfunction ">>>
    " s:move_up() <<<
    "   Moves the entity under the cursor up a line.
    function! s:move_up()
        let lineno=line('.')
        if lineno == 1
            return
        endif
        let fc=foldclosed('.')
        let a_reg=@a
        if lineno == line('$')
            normal! "add"aP
        else
            normal! "addk"aP
        endif
        let @a=a_reg
        if fc != -1
            normal! zc
        endif
    endfunction ">>>
    " s:move_down() <<<
    "   Moves the entity under the cursor down a line.
    function! s:move_down()
        let fc=foldclosed('.')
        let a_reg=@a
        normal! "add"ap
        let @a=a_reg
        if (fc != -1) && (foldclosed('.') == -1)
            normal! zc
        endif
    endfunction " >>>
    " s:display_info() <<<
    "   Displays filename and current working directory when i (info) is in
    "   the flags.
    function! s:display_info()
        if match(g:proj_flags, '\Ci') != -1
            let l:cwd = substitute(getcwd().'/', escape(expand('~'), ' \'), '~', '')
            let l:fn = substitute(expand('%:p'), escape(getcwd().'/', ' \'), '', '')
            echo '"'.l:fn.'"'.(&ro?'RO':'').', '.l:cwd.', '.line('$').'L'
            unlet l:cwd
        endif
    endfunction ">>>
    " s:setup_auto_command(cwd) <<<
    "   Sets up an autocommand to ensure that the cwd is set to the one
    "   desired for the fold regardless.  :lcd only does this on a per-window
    "   basis, not a per-buffer basis.
    function! s:setup_auto_command(cwd)
        if !exists("b:proj_has_autocommand")
            let b:proj_cwd_save = escape(getcwd(), ' ')
            let b:proj_has_autocommand = 1
            let bufname=escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ')
            exec 'au BufEnter '.bufname." let b:proj_cwd_save=escape(getcwd(), ' ') | cd ".a:cwd
            exec 'au BufLeave '.bufname.' exec "cd ".b:proj_cwd_save'
            exec 'au BufWipeout '.bufname.' au! * '.bufname
        endif
    endfunction ">>>
    " s:setup_script_auto_cmd(bufcmd, script) <<<
    "   Sets up an autocommand to run the scriptin script.
    function! s:setup_script_auto_cmd(bufcmd, script)
        if !exists("b:proj_has_".a:bufcmd)
            let b:proj_has_{a:bufcmd} = 1
            exec 'au '.a:bufcmd.' '.escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ').' source '.a:script
        endif
    endfunction " >>>
    " s:spawn(number) <<<
    "   spawn an external command on the file
    function! s:spawn(number)
        echo | if exists("g:proj_run".a:number)
            let fname=getline('.')
            if fname!~'{\|}'
                let fname=substitute(fname, '\s*#.*', '', '')
                let fname=substitute(fname, '^\s*\(.*\)\s*', '\1', '')
                if fname == '' | return | endif
                let parent_infoline = s:construct_directives_r(line('.'))
                let home=expand(s:get_home(parent_infoline, ''))
                let c_d=expand(s:get_cd(parent_infoline, ''))
                let command=substitute(g:proj_run{a:number}, '%%', "\010", 'g')
                let command=substitute(command, '%f', escape(home.'/'.fname, '\'), 'g')
                let command=substitute(command, '%F', substitute(escape(home.'/'.fname, '\'), ' ', '\\\\ ', 'g'), 'g')
                let command=substitute(command, '%s', escape(home.'/'.fname, '\'), 'g')
                let command=substitute(command, '%n', escape(fname, '\'), 'g')
                let command=substitute(command, '%N', substitute(fname, ' ', '\\\\ ', 'g'), 'g')
                let command=substitute(command, '%h', escape(home, '\'), 'g')
                let command=substitute(command, '%H', substitute(escape(home, '\'), ' ', '\\\\ ', 'g'), 'g')
                if c_d != ''
                    if c_d == home
                        let percent_r='.'
                    else
                        let percent_r=substitute(home, escape(c_d.'/', '\'), '', 'g')
                    endif
                else
                    let percent_r=home
                endif
                let command=substitute(command, '%r', percent_r, 'g')
                let command=substitute(command, '%R', substitute(percent_r, ' ', '\\\\ ', 'g'), 'g')
                let command=substitute(command, '%d', escape(c_d, '\'), 'g')
                let command=substitute(command, '%D', substitute(escape(c_d, '\'), ' ', '\\\\ ', 'g'), 'g')
                let command=substitute(command, "\010", '%', 'g')
                exec command
            endif
        endif
    endfunction ">>>
    " s:list_spawn(varnamesegment) <<<
    "   List external commands
    function! s:list_spawn(varnamesegment)
        let number = 1
        while number < 10
            if exists("g:proj_run".a:varnamesegment.number)
                echohl LineNr | echo number.':' | echohl None | echon ' '.substitute(escape(g:proj_run{a:varnamesegment}{number}, '\'), "\n", '\\n', 'g')
            else
                echohl LineNr | echo number.':' | echohl None
            endif
            let number=number + 1
        endwhile
    endfunction ">>>
    " s:find_fold_top(line) <<<
    "   Return the line number of the directive line
    function! s:find_fold_top(line)
        let lineno=a:line
        if getline(lineno) =~ '}'
            let lineno = lineno - 1
        endif
        while getline(lineno) !~ '{' && lineno > 1
            if getline(lineno) =~ '}'
                let lineno=s:find_fold_top(lineno)
            endif
            let lineno = lineno - 1
        endwhile
        return lineno
    endfunction ">>>
    " s:find_fold_bottom(line) <<<
    "   Return the line number of the directive line
    function! s:find_fold_bottom(line)
        let lineno=a:line
        if getline(lineno) =~ '{'
            let lineno=lineno + 1
        endif
        while getline(lineno) !~ '}' && lineno < line('$')
            if getline(lineno) =~ '{'
                let lineno=s:find_fold_bottom(lineno)
            endif
            let lineno = lineno + 1
        endwhile
        return lineno
    endfunction ">>>
    " s:load_all(recurse, line) <<<
    "   Load all files in a project
    function! s:load_all(recurse, line)
        let b:loadcount=0
        function! s:spawn_exec(infoline, fname, lineno, data)
            if s:open_entry_inner(a:lineno, a:infoline, a:fname, 'e')
                wincmd p
                let b:loadcount=b:loadcount+1
                echon b:loadcount."\r"
                if getchar(0) != 0
                    let b:stop_everything=1
                endif
            endif
        endfunction
        call Project_ForEach(a:recurse, line('.'), "*<SID>spawn_exec", 0, '^\(.*l\)\@!')
        delfunction s:spawn_exec
        echon b:loadcount." Files Loaded\r"
        unlet b:loadcount
        if exists("b:stop_everything") | unlet b:stop_everything | endif
    endfunction ">>>
    " s:wipe_all(recurse, line) <<<
    "   Wipe all files in a project
    function! s:wipe_all(recurse, line)
        let b:wipecount=0
        let b:totalcount=0
        function! s:spawn_exec(home, c_d, fname, lineno, data)
            let fname=escape(a:fname, ' ')
            if s:is_absolute_path(fname)
                let fname=fnamemodify(fname, ':n')  " :n is coming, won't break anything now
            else
                let fname=fnamemodify(a:home.'/'.fname, ':n')  " :n is coming, won't break anything now
            endif
            let b:totalcount=b:totalcount+1
            let fname=substitute(fname, '^\~', $HOME, 'g')
            if bufloaded(substitute(fname, '\\ ', ' ', 'g'))
                if getbufvar(fname.'\>', '&modified') == 1
                    exec 'sb '.fname
                    wincmd L
                    w
                    wincmd p
                endif
                let b:wipecount=b:wipecount+1
                exec 'bwipe! '.fname
            endif
            if b:totalcount % 5 == 0
                echon b:wipecount.' of '.b:totalcount."\r"
                redraw
            endif
            if getchar(0) != 0
                let b:stop_everything=1
            endif
        endfunction
        call Project_ForEach(a:recurse, line('.'), "<SID>spawn_exec", 0, '^\(.*w\)\@!')
        delfunction s:spawn_exec
        echon b:wipecount.' of '.b:totalcount." Files Wiped\r"
        unlet b:wipecount b:totalcount
        if exists("b:stop_everything") | unlet b:stop_everything | endif
    endfunction ">>>
    " s:grep_all(recurse, lineno, pattern) <<<
    "   Grep all files in a project, optionally recursively
    function! s:grep_all(recurse, lineno, pattern)
        let pattern=(a:pattern[0] == '')?input("GREP options and pattern: "):a:pattern
        if pattern[0] == ''
            return
        endif
        let b:escape_spaces=1
        let fnames=Project_GetAllFnames(a:recurse, a:lineno, ' ')
        unlet b:escape_spaces
        cclose " Make sure grep window is closed
        silent! write
        silent! exec 'silent! grep '.pattern.' '.fnames
        if v:shell_error == 1
            echo 'GREP: No matches found.'
        elseif v:shell_error == 2
            echo 'GREP error. '
        else
            copen
        endif
    endfunction ">>>
    " GetXXX Functions <<<
    function! s:get_home(info, parent_home)
        let home=substitute(a:info, '^[^=]*=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
        if strlen(home) == strlen(a:info)
            let home=substitute(a:info, '.\{-}"\(.\{-}\)".*', '\1', '')
            if strlen(home) != strlen(a:info) | let home=escape(home, ' ') | endif
        endif
        if strlen(home) == strlen(a:info)
            let home=a:parent_home
        elseif home=='.'
            let home=a:parent_home
        elseif !s:is_absolute_path(home)
            let home=a:parent_home.'/'.home
        endif
        return home
    endfunction
    function! s:get_filter(info, parent_filter)
        let filter = substitute(a:info, '.*\<filter="\([^"]*\).*', '\1', '')
        if strlen(filter) == strlen(a:info) | let filter = a:parent_filter | endif
        return filter
    endfunction
    function! s:get_cd(info, home)
        let c_d=substitute(a:info, '.*\<cd=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
        if strlen(c_d) == strlen(a:info)
            let c_d=substitute(a:info, '.*\<cd="\(.\{-}\)".*', '\1', '')
            if strlen(c_d) != strlen(a:info) | let c_d=escape(c_d, ' ') | endif
        endif
        if strlen(c_d) == strlen(a:info)
            let c_d=''
        elseif c_d == '.'
            let c_d = a:home
        elseif !s:is_absolute_path(c_d)
            let c_d = a:home.'/'.c_d
        endif
        return c_d
    endfunction
    function! s:get_script_in(info, home)
        let scriptin = substitute(a:info, '.*\<in=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
        if strlen(scriptin) == strlen(a:info)
            let scriptin=substitute(a:info, '.*\<in="\(.\{-}\)".*', '\1', '')
            if strlen(scriptin) != strlen(a:info) | let scriptin=escape(scriptin, ' ') | endif
        endif
        if strlen(scriptin) == strlen(a:info) | let scriptin='' | else
        if !s:is_absolute_path(scriptin) | let scriptin=a:home.'/'.scriptin | endif | endif
        return scriptin
    endfunction
    function! s:get_script_out(info, home)
        let scriptout = substitute(a:info, '.*\<out=\(\(\\ \|\f\|:\)\+\).*', '\1', '')
        if strlen(scriptout) == strlen(a:info)
            let scriptout=substitute(a:info, '.*\<out="\(.\{-}\)".*', '\1', '')
            if strlen(scriptout) != strlen(a:info) | let scriptout=escape(scriptout, ' ') | endif
        endif
        if strlen(scriptout) == strlen(a:info) | let scriptout='' | else
        if !s:is_absolute_path(scriptout) | let scriptout=a:home.'/'.scriptout | endif | endif
        return scriptout
    endfunction
    function! s:get_flags(info)
        let flags=substitute(a:info, '.*\<flags=\([^ {]*\).*', '\1', '')
        if (strlen(flags) == strlen(a:info))
            let flags=''
        endif
        return flags
    endfunction ">>>
    " Project_GetAllFnames(recurse, lineno, separator) <<<
    "   Grep all files in a project, optionally recursively
    function! Project_GetAllFnames(recurse, lineno, separator)
        let b:fnamelist=''
        function! s:spawn_exec(home, c_d, fname, lineno, data)
            if exists('b:escape_spaces')
                let fname=escape(a:fname, ' ')
            else
                let fname=a:fname
            endif
            if !s:is_absolute_path(a:fname)
                let fname=a:home.'/'.fname
            endif

            let fname = substitute(expand(fname), getcwd().'/', '', '')

            let b:fnamelist=b:fnamelist.a:data.fname
        endfunction
        call Project_ForEach(a:recurse, line('.'), "<SID>spawn_exec", a:separator, '')
        delfunction s:spawn_exec
        let retval=b:fnamelist
        unlet b:fnamelist
        return retval
    endfunction ">>>
    " Project_GetAllFnames(recurse, lineno, separator) <<<
    "   Grep all files in a project, optionally recursively
    function! Project_GetFname(line)
        if (foldlevel(a:line) == 0)
            return ''
        endif
        let fname=substitute(getline(a:line), '\s*#.*', '', '') " Get rid of comments and whitespace before comment
        let fname=substitute(fname, '^\s*\(.*\)', '\1', '') " Get rid of leading whitespace
        if strlen(fname) == 0
            return ''                    " The line is blank. Do nothing.
        endif
        if s:is_absolute_path(fname)
            return fname
        endif
        let infoline = s:construct_directives_r(a:line)
        return s:get_home(infoline, '').'/'.fname
    endfunction ">>>
    " Project_ForEach(recurse, lineno, cmd, data, match) <<<
    "   Grep all files in a project, optionally recursively
    function! Project_ForEach(recurse, lineno, cmd, data, match)
        let info=s:construct_directives_r(a:lineno)
        let lineno=s:find_fold_top(a:lineno) + 1
        let flags=s:get_flags(getline(lineno - 1))
        if (flags == '') || (a:match=='') || (match(flags, a:match) != -1)
            call s:project_foreach_r(a:recurse, lineno, info, a:cmd, a:data, a:match)
        endif
    endfunction
    function! s:project_foreach_r(recurse, lineno, info, cmd, data, match)
        let home=s:get_home(a:info, '')
        let c_d=s:get_cd(a:info, home)
        let scriptin = s:get_script_in(a:info, home)
        let scriptout = s:get_script_out(a:info, home)
        let filter = s:get_filter(a:info, '')
        let lineno = a:lineno
        let curline=getline(lineno)
        while curline !~ '}' && curline < line('$')
            if exists("b:stop_everything") && b:stop_everything | return 0 | endif
            if curline =~ '{'
                if a:recurse
                    let flags=s:get_flags(curline)
                    if (flags == '') || (a:match=='') || (match(flags, a:match) != -1)
                        let this_home=s:get_home(curline, home)
                        let this_cd=s:get_cd(curline, this_home)
                        if this_cd=='' | let this_cd=c_d | endif
                        let this_scriptin=s:get_script_in(curline, this_home)
                        if this_scriptin == '' | let this_scriptin=scriptin | endif
                        let this_scriptout=s:get_script_in(curline, this_home)
                        if this_scriptout == '' | let this_scriptout=scriptout | endif
                        let this_filter=s:get_filter(curline, filter)
                        let lineno=s:project_foreach_r(1, lineno+1,
                            \s:construct_info(this_home, this_cd, this_scriptin, this_scriptout, flags, this_filter), a:cmd, a:data, a:match)
                    else
                        let lineno=s:find_fold_bottom(lineno)
                    endif
                else
                    let lineno=s:find_fold_bottom(lineno)
                endif
            else
                let fname=substitute(curline, '\s*#.*', '', '')
                let fname=substitute(fname, '^\s*\(.*\)', '\1', '')
                if (strlen(fname) != strlen(curline)) && (fname[0] != '')
                    if a:cmd[0] == '*'
                        call {strpart(a:cmd, 1)}(a:info, fname, lineno, a:data)
                    else
                        call {a:cmd}(home, c_d, fname, lineno, a:data)
                    endif
                endif
            endif
            let lineno=lineno + 1
            let curline=getline(lineno)
        endwhile
        return lineno
    endfunction ">>>
    " s:spawn_all(recurse, number) <<<
    "   spawn an external command on the files of a project
    function! s:spawn_all(recurse, number)
        echo | if exists("g:proj_run_fold".a:number)
            if g:proj_run_fold{a:number}[0] == '*'
                function! s:spawn_exec(home, c_d, fname, lineno, data)
                    let command=substitute(strpart(g:proj_run_fold{a:data}, 1), '%s', escape(a:fname, ' \'), 'g')
                    let command=substitute(command, '%f', escape(a:fname, '\'), 'g')
                    let command=substitute(command, '%h', escape(a:home, '\'), 'g')
                    let command=substitute(command, '%d', escape(a:c_d, '\'), 'g')
                    let command=substitute(command, '%F', substitute(escape(a:fname, '\'), ' ', '\\\\ ', 'g'), 'g')
                    exec command
                endfunction
                call Project_ForEach(a:recurse, line('.'), "<SID>spawn_exec", a:number, '.')
                delfunction s:spawn_exec
            else
                let info=s:construct_directives_r(line('.'))
                let home=s:get_home(info, '')
                let c_d=s:get_cd(info, '')
                let b:escape_spaces=1
                let fnames=Project_GetAllFnames(a:recurse, line('.'), ' ')
                unlet b:escape_spaces
                let command=substitute(g:proj_run_fold{a:number}, '%f', substitute(escape(fnames, '\'), '\\ ', ' ', 'g'), 'g')
                let command=substitute(command, '%s', escape(fnames, '\'), 'g')
                let command=substitute(command, '%h', escape(home, '\'), 'g')
                let command=substitute(command, '%d', escape(c_d, '\'), 'g')
                let command=substitute(command, '%F', escape(fnames, '\'), 'g')
                exec command
                if v:shell_error != 0
                    echo 'Shell error, return code' v:shell_error
                endif
            endif
        endif
    endfunction ">>>

function! s:do_project(filename)

    if exists("g:proj_running") 
        if bufwinnr(g:proj_running) != -1
            if fnamemodify(bufname(g:proj_running), ':t') == s:defname
                " Found it in the current windows, switch to it.
                execute bufwinnr(g:proj_running)."wincmd w"
                return
            endif
        endif
    endif

    if strlen(a:filename) == 0
        let filename = s:defname
    else
        let filename = a:filename
    endif

    " Load the Project File in current Window
    if &modified
        new
    endif

    lcd ~

    " Now create new buffer
    if filereadable(filename.'.swp')
        exec 'silent vie '.filename
        setl nomodifiable
    else
        " If buffer exists, but Window closed, re-open the buffer and return.
        if exists("g:proj_running") 
            if strlen( bufname(g:proj_running) )
                exec 'silent! b! '.g:proj_running
                call s:display_info()
                return
            endif
        endif
        exec 'silent e '.filename
    endif
    call s:display_info()


    " Process the flags
    let b:proj_cd_cmd='cd'
    if match(g:proj_flags, '\Cl') != -1
        let b:proj_cd_cmd = 'lcd'
    endif

    setl ft=vimproj

    " Mappings are retained the for buffer, even if the Window are hidden
    if !exists("g:proj_running")
        nnoremap <buffer> <silent> <Return>   \|:call <SID>fold_or_open_entry('', 'e')<CR>
        nnoremap <buffer> <silent> gf  \|:call <SID>fold_or_open_entry('', 'e')<CR>
        nnoremap <buffer> <silent> <LocalLeader>ji :echo <SID>construct_directives_r(line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jI :echo Project_GetFname(line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jl \|:call <SID>load_all(0, line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jL \|:call <SID>load_all(1, line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jw \|:call <SID>wipe_all(0, line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jW \|:call <SID>wipe_all(1, line('.'))<CR>
        nnoremap <buffer> <silent> <LocalLeader>jg \|:call <SID>grep_all(0, line('.'), "")<CR>
        nnoremap <buffer> <silent> <LocalLeader>jG \|:call <SID>grep_all(1, line('.'), "")<CR>
        nnoremap <buffer> <silent> <2-LeftMouse>   \|:call <SID>fold_or_open_entry('', 'e')<CR>
        nnoremap <buffer> <silent> <3-LeftMouse>  <Nop>
        nnoremap <buffer> <silent> <C-Up>   \|:silent call <SID>move_up()<CR>
        nnoremap <buffer> <silent> <C-Down> \|:silent call <SID>move_down()<CR>

        if 0
        let k=10
        while k
            exec 'nnoremap <buffer> <LocalLeader>j'.k.'  \|:call <SID>spawn('.k.')<CR>'
            exec 'nnoremap <buffer> <LocalLeader>jf'.k.' \|:call <SID>spawn_all(0, '.k.')<CR>'
            exec 'nnoremap <buffer> <LocalLeader>jF'.k.' \|:call <SID>spawn_all(1, '.k.')<CR>'
            let k=k-1
        endwhile

        nnoremap <buffer>          <LocalLeader>j0 \|:call <SID>list_spawn("")<CR>
        nnoremap <buffer>          <LocalLeader>jf0 \|:call <SID>list_spawn("_fold")<CR>
        nnoremap <buffer>          <LocalLeader>jF0 \|:call <SID>list_spawn("_fold")<CR>
        en

        nnoremap <buffer> <silent> <LocalLeader>jc :call <SID>create_entries_from_dir(0)<CR>
        nnoremap <buffer> <silent> <LocalLeader>jC :call <SID>create_entries_from_dir(1)<CR>
        nnoremap <buffer> <silent> <LocalLeader>jr :call <SID>refresh_entries_from_dir(0)<CR>
        nnoremap <buffer> <silent> <LocalLeader>jR :call <SID>refresh_entries_from_dir(1)<CR>
        nnoremap <buffer> <silent> <LocalLeader>je :call <SID>open_entry(line('.'), '', '', 0)<CR>
        nnoremap <buffer> <silent> <LocalLeader>jE :call <SID>open_entry(line('.'), '', 'e', 1)<CR>

        " Autocommands to clean up if we do a buffer wipe
        " These don't work unless we substitute \ for / for Windows
        let bufname=escape(substitute(expand('%:p', 0), '\\', '/', 'g'), ' ')
        exec 'au BufWipeout '.bufname.' au! * '.bufname
        exec 'au BufWipeout '.bufname.' unlet g:proj_running'

        setlocal buflisted
        let g:proj_running = bufnr(bufname.'\>')
        if g:proj_running == -1
            echo 'Project/Vim error. Please Enter :Project again and report this bug.'
            unlet g:proj_running
        endif
        setlocal nobuflisted
    endif
endfunction

command! -nargs=? Project call <SID>do_project('<args>')

" vim:nowrap:
