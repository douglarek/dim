curl -fLo ~/.vimrc https://raw.githubusercontent.com/douglarek/nvimrc/master/.vimrc

curl -fLo ~/.config/nvim/init.vim --create-dirs https://raw.githubusercontent.com/douglarek/nvimrc/master/init.vim

curl -fLo ~/.config/fish/functions/nvimrc.fish --create-dirs https://raw.githubusercontent.com/douglarek/nvimrc/master/nvimrc.fish

nvim +PlugInstall +qall

echo "WARN: \`(sudo) pip install neovim\` if you use neovim"
