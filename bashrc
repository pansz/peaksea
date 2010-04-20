# my common bashrc inside vim files

alias apb='sudo aptitude build-dep'
alias api='sudo aptitude install'
alias apr='sudo aptitude remove'
alias aps='aptitude search'
alias apu='sudo aptitude update && sudo aptitude full-upgrade'
alias apw='aptitude show'
alias apy='aptitude why'
alias s='screen'
ulimit -c 2048
export EDITOR=vi
export LANG="zh_CN.UTF-8"
export LANGUAGE=en_US:zh

_show_all()
{
        local cur
        COMPREPLY=()
        cur=`_get_cword`
        COMPREPLY=( $( apt-cache pkgnames $cur 2> /dev/null ) )
        return 0
}
complete -F _show_all $default api
complete -F _show_all $default apd
complete -F _show_all $default aps
complete -F _show_all $default apw

