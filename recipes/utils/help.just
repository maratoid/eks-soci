# command help
[no-exit-message]
help *command:
    #!{{ shebang }}
    subhelps=""
    if (( $# == 0 )); then
        for module in recipes/modules/*/ ; do
            subhelps="${subhelps}\njust help ${module:t:r}"
        done
    elif (( $# == 1 )); then
        if ! [ -d recipes/modules/$1/help ]; then
            echo "No help for command $1"
            exit 1
        fi

        for md_file in recipes/modules/$1/help/*.md; do
            subhelps="${subhelps}\njust help $1 ${md_file:t:r}"
        done
    elif (( $# == 2 )); then
        if ! [ -d recipes/modules/$1/help ]; then
            echo "No help for command $1"
            exit 1
        fi

        if ! [ -f recipes/modules/$1/help/$2.md ]; then
            echo "No help for command $1 $2"
            exit 1
        fi

        glow -w {{ env_var('JUST_GLOW_HELP_WIDTH') }} -p recipes/modules/$1/help/$2.md
        exit 0
    else 
        echo "Too many arguments! Use 'just help [command] [sub-command]'"
        exit 1;
    fi

    echo -e "\nUse:\n${subhelps}\n"