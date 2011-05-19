#!/bin/sh
# init my environment
cd
ln -sf .vim/bashrc .bash_aliases
ln -sf .vim/gvimrc .gvimrc
ln -sf .vim/hgrc .hgrc
ln -sf .vim/indent.pro .indent.pro
ln -sf .vim/inputrc .inputrc
ln -sf .vim/screenrc .screenrc
ln -sf .vim/vimrc .vimrc
ln -sf .vim/Xresources .Xresources
mkdir -p ~/.vimtmp

checkdir() {
    if [ -d $chn ]; then
        mv $chn $eng
    else
        #mkdir -p $eng
        echo
    fi
}

chn="公共的"
eng=pub
checkdir

chn="模板"
eng=temp
checkdir

chn="视频"
eng=video
checkdir

chn="图片"
eng=pic
checkdir

chn="文档"
eng=doc
checkdir

chn="音乐"
eng=music
checkdir

chn="桌面"
eng=wall
checkdir

chn="下载"
eng=download
checkdir

mkdir -p .config
cd .config
rm -f user-dirs.dirs
ln -sf ../.vim/user-dirs.dirs user-dirs.dirs

