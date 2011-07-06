" Vim script file --- netlog.vim
" Maintainer:	Pan, Shi Zhu
" Last Change:	6 Jul 2011
" Version:	0.4
"
"	Netlog print log information and show it on another terminal window in
"	local or remote computer. 
"
"       You need to run ./logserver on somewhere, by default you should run it
"       on your local computer.
"
" Usage:
"	you may source it inside .vimrc, or you may include the whole content 
"	in your script, or you may source it inside your script.
"
"       put something in your script as following
"
"       :sil! call Netlog('debug', 'foo/bar is', foobar, 'and', bar)
"
"       For the above method you can inspect some expressions. The first
"       argument specifies log level which must be one of the following:
"
"	"emerg"		/* system is unusable */
"	"alert"		/* action must be taken immediately */
"	"crit"		/* critical conditions */
"	"err"		/* error conditions */
"	"warning"	/* warning conditions */
"	"notice"	/* normal but significant condition */
"	"info"		/* informational */
"	"debug"		/* debug-level messages */
"
"	In case you want to set the debug level:
"
"	:sil! call Netlog_setmask('err,info,debug')
"
"	For the above method you can set the masked log level, you can set any
"	combination from the above 8 levels.
"
"	By default, mask will be set to enable everything except "debug"
"
"
" Optional Settings:
"	You don't have to set them, they will have the default value.
"
"	:let g:netlog_enabled=1
"	set the above to globally enable/disable netlog
"
"	:let g:netlog_host="localhost"
"       set the above to specify the ip address or domain name where you run logserver
"
"	:let g:netlog_port=10007
"       set the above to specify which port you run logserver
"
"	:let g:netlog_cmd=0
"	set the above with 1 to define Netlog command as plain text output.
"

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
def log_mask(level):
    pri = g_level.get(level, -1)
    if pri < 0:
        return 0
    else:
        return 1 << pri
def log_upto(level):
    pri = g_level.get(level, -1)
    return (1 <<(pri+1) ) - 1
def checkmask(level):
    if log_mask(level) & g_mask:
        return True
    else:
        return False

g_host = vim.eval("g:netlog_host")
g_port = int(vim.eval("g:netlog_port"))
g_level = {"emerg":0, "alert":1, "crit":2, "err":3, "warning":4, "notice":5, "info":6, "debug":7 }
g_mask = log_upto("info")

PYTHON
        endfunction

        call s:netlog_python_init()

        function! Netlog_setmask(mask)
            :sil!python << PYTHON
g_mask = 0
for item in vim.eval("a:mask").split(","):
    g_mask |= log_mask(item)
PYTHON
        endfunction

        function! Netlog(...)
            if !empty(g:netlog_enabled)
                :sil!python << PYTHON
try:
    level = vim.eval("a:1")
    if checkmask(level):
        udpsend(vim.eval("join(a:000)"))
except vim.error:
    print("vim error: %s" % vim.error)
PYTHON
            endif
        endfunction

    else	" besides python, we may support libcall in the future
        function! Netlog_setmask(mask)
            " define an empty function
        endfunction
        function! Netlog(...)
            " define an empty function
        endfunction
    endif

    call Netlog('info', 'Netlog started at', strftime('%c'))
    if !empty("g:netlog_cmd")
        command! -nargs=+ Netlog call Netlog(<f-args>)
    endif

endif	" loaded_netlog

" vim: ts=8 sw=4 noet 
