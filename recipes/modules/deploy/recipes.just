# Deploy all required components to k3s cluster
[no-cd]
all: (certmanager "create") (buildkit "create")

# Operate certmanager deployment in k3s cluster: action=create|destroy [version]
[no-cd]
certmanager action *version=just_certmanager_version:
    #!{{ shebang_strict }}

    {{ just_call }} _params "action" {{ action }} create destroy
    {{ just_call }} deploy _certmanager_{{ action }} {{ version}}

# Operate build kit deployment in k3s cluster: buildkit action=create|destroy|dryrun|dump|vals|schema|objects|rollout [values...]
[no-cd]
buildkit action *values:
    #!{{ shebang_strict }}

    {{ just_call }} _params "action" {{ action }} create destroy dryrun dump vals schema objects rollout

    if [[ "{{ action }}" == "rollout" ]]; then
        kubectl rollout restart statefulset {{ just_builder_base_name }}-ss -n {{ just_builder_namespace }}
        kubectl rollout status --watch --timeout=600s statefulset/{{ just_builder_base_name }}-ss -n {{ just_builder_namespace }}
        exit 0
    fi

    # calculate values paths
    values_str="{{ values }}"
    values=(${values_str})
    values_len=${#values[@]}

    value_paths_param=""
    if (( values_len > 0 )); then 
        real_paths=()
        for path in "${values[@]}"; do
            real_paths+=($({{ just_call }} _relative_paths "deploy" "${path}"))
        done
        printf -v value_paths_param '%s,' "${real_paths[@]}"
        value_paths_param="${value_paths_param%,}"
    fi 

    if [[ "${value_paths_param}" != "" ]]; then
        value_paths_param="-t values=${value_paths_param}"
    fi

    cd deploy

    if [[ "{{ action }}" == "create" ]]; then
        cue cmd apply -t namespace={{ just_builder_namespace }} ${value_paths_param}
        kubectl rollout status --watch --timeout=600s statefulset/{{ just_builder_base_name }}-ss -n {{ just_builder_namespace }}
    elif [[ "{{ action }}" == "dryrun" ]]; then
        cue cmd dryrun -t namespace={{ just_builder_namespace }} ${value_paths_param}
    elif [[ "{{ action }}" == "dump" ]]; then
        cue cmd dump -t namespace={{ just_builder_namespace }} ${value_paths_param}
    elif [[ "{{ action }}" == "vals" ]]; then
        cue cmd vals -t namespace={{ just_builder_namespace }} ${value_paths_param}
    elif [[ "{{ action }}" == "schema" ]]; then
        cue def ./values -e '#Values' | sed '1,4d; $d; s/\t//'
    elif [[ "{{ action }}" == "objects" ]]; then
        cue cmd ls -t namespace={{ just_builder_namespace }} ${value_paths_param}
    else
        cue cmd delete -t namespace={{ just_builder_namespace }} ${value_paths_param}
    fi

[no-cd]
_certmanager_create version: 
    #!{{ shebang_strict }}

    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v{{ version }}/cert-manager.crds.yaml
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v{{ version }}/cert-manager.yaml
    kubectl wait --for=condition=available deployment/cert-manager-webhook -n cert-manager --timeout=60s

[no-cd]
_certmanager_destroy version: 
    #!{{ shebang_strict }}

    kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v{{ version }}/cert-manager.yaml
    kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v{{ version }}/cert-manager.crds.yaml