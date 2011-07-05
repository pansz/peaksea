" Vim plugin file --- netlog.vim
" Maintainer:	Pan, Shi Zhu
" Last Change:	5 Jul 2011
" Version:	0.2
"
"	Netlog print log information and show it on another terminal window in
"	local or remote computer, you may source it inside .vimrc, or you may
"	include the whole content in your script, or you may source it inside
"	your script.
"
" Usage:
"       put something in your script as following and make sure netlog.vim 
"       sourced before your script, e.g. .vimrc are sourced before .vim/plugin.
"
"       :sil! call Netlog('var foo/bar is', foobar, 'and', bar)
"       For the above method you can inspect some expressions.
"
"       :sil! Netlog Let us output some plain text here.
"       For the above method you can only print plain text.
"
" Relavent Settings:
"	You don't have to set anyone, they will have the default value.
"
"	:let g:netlog_enabled=1
"	set the above to enable/disable netlog
"
"	:let g:netlog_host="localhost"
"       set the above to specify where you run logserver
"
"	:let g:netlog_port=10007
"       set the above to specify which port you run logserver
"
" Note: 
"       You need to run ./logserver on somewhere, by default you should run it
"       on your local computer.

if !exists ("g:loaded_netlog")
    let g:loaded_netlog = 1

    if !exists("g:netlog_host")
        let g:netlog_host="localhost"
    endif

    if !exists("g:netlog_port")
        let g:netlog_port=10007
    endif

    if !exists("g:netlog_enabled")
        let g:netlog_enabled=1
    endif

    if has("python")

        function! s:netlog_python_init()
            :sil!python << PYTHON
import vim, sys, socket
BUFSIZE = 1024
def udpslice(sendfunc, data, addr):
    senddata = data
    while len(senddata) >= BUFSIZE:
        sendfunc(senddata[0:BUFSIZE], addr)
        senddata = senddata[BUFSIZE:]
    if senddata[-1:] == "\n":
        sendfunc(senddata, addr)
    else:
        sendfunc(senddata+"\n", addr)
def udpsend(data):
    addr = g_host, g_port
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(1)
    try:
        s.bind(('', 0))
    except Exception, inst:
        s.close()
        return None
    ret = ""
    for item in data.split("\n"):
        if item == "":
            continue
        udpslice(s.sendto, item, addr)
    s.close()
def netlog(*args):
    data = " ".join(args)
    udpsend(data)

g_host = vim.eval("g:netlog_host")
g_port = int(vim.eval("g:netlog_port"))

PYTHON
        endfunction

        call s:netlog_python_init()

        function! Netlog(...)
            if !empty(g:netlog_enabled)
                :sil!python << PYTHON
try:
    udpsend(vim.eval("join(a:000)"))
except vim.error:
    print("vim error: %s" % vim.error)
PYTHON
            endif
        endfunction

    else	" besides python, we may support libcall in the future
        function! Netlog(...)
            " define an empty function
        endfunction
    endif

    call Netlog('Netlog started at', strftime('%c'))
    command! -nargs=+ Netlog call Netlog(<q-args>)

endif	" loaded_netlog
