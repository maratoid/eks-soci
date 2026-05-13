# create new just command with subcommand and optional [params]
[no-cd]
[no-exit-message]
scaffold command subcommand *params:
    #!{{ shebang }}

    # check if command exists
    command_exists="no"
    if [ -d recipes/modules/{{ command }} ]; then
        command_exists="yes"
        if [ -f recipes/modules/{{ command }}/{{ subcommand }}.just ]; then
            echo "'{{ command }}' subcommand '{{ subcommand }}' already exists!"
            exit 1
        fi
    fi

    # create command module folder
    mkdir -p recipes/modules/{{ command }}/help

    subcommands_array=("{{ subcommand }}")

    # if command already exists, collect its sub-commands
    if [[ "${command_exists}" = "yes" ]]; then
        for just_file in recipes/modules/{{ command }}/*.just ; do
            if [[ "${just_file:t:r}" != "module" ]]; then
                subcommands_array+=(${just_file:t:r})
            fi
        done
    fi
    subcommands_json=$(jq --compact-output \
        --null-input '$ARGS.positional' \
        --args -- "${subcommands_array[@]}")

    # template data to command's module.just
    echo "{\"name\": \"{{ command }}\", \"subcommands\": ${subcommands_json}}" | \
        gomplate -f recipes/modules/code/config/command.tpl \
        -d module=stdin:///temp.json > recipes/modules/{{ command }}/module.just

    # template data to subcommand just file
    params_array=({{ params }})
    params_json=$(jq --compact-output \
        --null-input '$ARGS.positional' \
        --args -- "${params_array[@]}")
    echo "{\"name\": \"{{ subcommand }}\", \"params\": ${params_json}}" | \
        gomplate -f recipes/modules/code/config/subcommand.tpl \
        -d subcommand=stdin:///temp.json > recipes/modules/{{ command }}/{{ subcommand }}.just
    
    # template data to subcommand help md file
    echo "{\"parent\": \"{{ command }}\", \"name\": \"{{ subcommand }}\", \"params\": ${params_json}}" | \
        gomplate -f recipes/modules/code/config/subcommand_help.tpl \
        -d subcommand=stdin:///temp.json > recipes/modules/{{ command }}/help/{{ subcommand }}.md

    # update justfile imports
    if [[ "${command_exists}" != "yes" ]]; then
        sed -i "1s,^,mod {{ command }} 'recipes/modules/{{ command }}/module.just'\n," justfile
    fi