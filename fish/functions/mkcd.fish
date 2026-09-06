function mkcd --description 'Create a directory and cd into it'
    if test -z "$argv[1]"
        echo "mkcd: missing directory name"
        return 1
    end
    mkdir -p -- $argv[1]; and cd -- $argv[1]
end
