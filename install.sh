curl -fLo ~/.vimrc https://raw.githubusercontent.com/douglarek/dim/master/.vimrc

curl -fLo ~/.config/nvim/init.vim --create-dirs https://raw.githubusercontent.com/douglarek/dim/master/init.vim

curl -fLo ~/.config/fish/functions/dim.fish --create-dirs https://raw.githubusercontent.com/douglarek/dim/master/dim.fish

nvim +PlugInstall +qall

echo "WARN: \`(sudo) pip install neovim\` if you use neovim"
