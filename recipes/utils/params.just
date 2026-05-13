[no-exit-message]
_params param_name param_value +supported_inputs="yes no": 
    #!{{ shebang }}
    param_value=({{ supported_inputs }})

    [[ ! " ${param_value[*]} " =~ " {{ param_value }} " ]] && \
        { echo "Unsupported {{ param_name }} value '{{ param_value }}'! Supported values are: ${param_value[@]}"; exit 1; } || true