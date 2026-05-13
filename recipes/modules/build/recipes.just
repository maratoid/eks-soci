# build SOCI v2 image
[no-cd]
soci *args:
    #!{{ shebang_strict }}

    buildTag=""

    while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--tag)
        buildTag="$2"
        shift 2
        ;;
        *)
        shift
        ;;
    esac
    done

    if [[ "${buildTag}" == "" ]]; then
        echo "'-t' or '--tag' argument is required!"
        exit 1
    fi

    builderNum="$({{ just_call }} build hash ${buildTag})"
    docker buildx use "{{ just_builder_base_name }}-${builderNum}"
    docker buildx build {{ args }}

    githubToken=""
    if [[ "{{ just_pass_gh_token }}" == "yes" ]]; then
        githubToken=$(gh auth token)
    fi

    dockerEnvUsrRegex='^DOCKER_.*_USR=.+$'
    dockerEnvPwdRegex='^DOCKER_.*_PSW=.+$'
    dockerEnvCreds=()
    while IFS='=' read -r name value; do
        if [[ "$name=$value" =~ $dockerEnvUsrRegex ]]; then
            dockerEnvCreds+=("${name}=${value}")
        fi
        if [[ "$name=$value" =~ $dockerEnvPwdRegex ]]; then
            dockerEnvCreds+=("${name}=${value}")
        fi
    done < <(env)

    dockerEnvCredsString="${dockerEnvCreds[*]}"
    kubectl exec {{ just_builder_base_name }}-ss-${builderNum} -n {{ just_builder_namespace }} -c containerd -- env GITHUB_TOKEN="${githubToken}" ${dockerEnvCredsString} /soci.sh ${buildTag} buildkit

# Get consistent hash mapping of a tag to builder number
[no-cd]
hash tag:
    #!{{ shebang_strict }}
    
    num_replicas=$({{ just_call }} builders number)
    nodes=()
    for i in $(seq 0 $((num_replicas-1))); do
        nodes+=("${i}")
    done

    node_string="${nodes[*]}"
    hash="$(kubectl exec {{ just_builder_base_name }}-ss-0 -n {{ just_builder_namespace }} -c containerd -- consistenthash {{tag}} ${node_string})"
    echo -n "${hash}"