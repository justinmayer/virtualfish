while true
    # Read in command
    set -e cmd
    read -z cmd
    if test "$cmd" = ""
        exit
    end

    # Run command
    echo $cmd | source
    set _status $status

    # Report that the command has finished (and print status on stdout)
    echo -ne "\0"
    echo -ne "\0" >&2
    echo $_status
    echo -ne "\0"
end
