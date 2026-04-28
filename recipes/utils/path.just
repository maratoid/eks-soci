# check if a path is in the PATH environment variable
_is_in_path path:
    #!{{ shebang_strict }}

    if [[ ":$PATH:" == *"{{ path }}:"* ]]; then
        echo -n "yes"
    else
        echo -n "no"
    fi

# get relative paths for a list of paths relative to a base path
[no-cd]
_relative_paths relative_to +paths:
    #!{{ shebang_strict }}

    paths_str="{{ paths }}"
    paths=(${paths_str})
    relative_paths=()

    for path in "${paths[@]}"; do
        relative_paths+=($(realpath --relative-to={{ relative_to }} ${path}))
    done

    echo -n "${relative_paths[@]}"