function nvimrc
  set cmd $argv[1]
  switch "$cmd"
    case update
        curl -s https://raw.githubusercontent.com/douglarek/nvimrc/master/install.sh | sh
    case '*'
        echo "Plesae use `nvimrc update`"
    end
end
