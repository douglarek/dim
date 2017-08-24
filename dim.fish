function dim
  set cmd $argv[1]
  switch "$cmd"
    case update
        curl -s https://raw.githubusercontent.com/douglarek/dim/master/install.sh | sh
    case '*'
        echo "Plesae use `dim update`"
    end
end
