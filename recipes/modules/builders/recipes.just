# Perform local builder setup 
[no-cd]
setup:
    #!{{ shebang_strict }}

    num_replicas=$({{ just_call }} builders number)
    for i in $(seq 0 $((num_replicas-1))); do
        docker buildx rm --force {{ just_builder_base_name }}-${i} > /dev/null 2>&1 || true
        docker buildx create --name {{ just_builder_base_name }}-${i} --node {{ just_builder_base_name }}-${i} --driver remote \
            kube-pod://{{ just_builder_base_name }}-ss-${i}?namespace={{ just_builder_namespace }}
    done

# Output local builder information
[no-cd]
info:
    @docker buildx ls

# Set active builder number
[no-cd]
use builder_num:
    @docker buildx use {{ just_builder_base_name }}-{{ builder_num}}

# Get number of active builders
[no-cd]
number:
    @kubectl get statefulset {{ just_builder_base_name }}-ss -n {{ just_builder_namespace }} -o json | jq '.status.replicas' 