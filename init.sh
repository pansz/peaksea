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
cd .config
rm -f user-dirs.dirs
ln -sf ../.vim/user-dirs.dirs user-dirs.dirs
