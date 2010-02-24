setlocal nowrap
if !exists("g:loaded_myescape")
    let g:loaded_myescape = 1
    function s:myescape(cmd)
        let l:esccmd = shellescape(a:cmd, 1)
        return strpart(l:esccmd, 1, strlen(l:esccmd)-2)
    endfunction
endif
nnoremap <buffer> <C-K> 0"ky$:silent !<C-R>=<sid>myescape(@k)<cr><cr><C-L>
nnoremap <buffer> g<C-K> 0"ky$:echo system(@k)<cr>

