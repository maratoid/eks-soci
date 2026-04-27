# check if a path is in the PATH environment variable
_is_in_path path:
    #!{{ shebang_strict }}

    if [[ ":$PATH:" == *"{{ path }}:"* ]]; then
        echo -n "yes"
    else
        echo -n "no"
    fi

# get relative paths for a list of paths relative to a base path
_relative_paths relative_to +paths:
    #!{{ shebang_strict }}

    paths="{{ paths }}"
    relative_paths=()

    for path in $paths; do
        if [[ "${path}" = /* ]]; then
            relative_paths+=("$(realpath --relative-to={{ relative_to }} ${path})")
        else
            relative_paths+=("${path}")
        fi
    done

    echo -n "${relative_paths[@]}"