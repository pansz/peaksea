# my common bashrc inside vim files

# set a fancy prompt
case "$TERM" in
xterm*)
    TITLEBAR='\[\e]0;\u@\h:\w\a\]'
    PS1="${TITLEBAR}"'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    ;;
screen*)
    PATHTITLE='\[\ek\W\e\\\]'
    PROGRAMTITLE='\[\ek\e\\\]'
    PS1="${PROGRAMTITLE}${PATHTITLE}"'\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    ;;
*)
    PS1='\u@\h:\w\$ '
    ;;
esac

alias ags='apt-get source'
alias apb='sudo aptitude build-dep'
alias api='sudo aptitude -R install'
alias apr='sudo aptitude remove'
alias aps='aptitude search'
alias apu='sudo aptitude update && sudo aptitude full-upgrade'
alias apw='aptitude show'
alias apy='aptitude why'
alias s='screen'
alias pshs='python -m SimpleHTTPServer'
ulimit -c 2048
export EDITOR=vi
export LANG="zh_CN.UTF-8"
export LANGUAGE=en_US:zh
export LS_COLORS='di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32'

_show_all()
{
        local cur
        COMPREPLY=()
        cur=`_get_cword`
        COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
        return 0
}
complete -F _show_all $default ags
complete -F _show_all $default apb
complete -F _show_all $default api
complete -F _show_all $default apr
complete -F _show_all $default aps
complete -F _show_all $default apu
complete -F _show_all $default apw
complete -F _show_all $default apy

