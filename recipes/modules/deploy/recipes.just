# Operate certmanager deployment in k3s cluster: action=create|destroy [version]
[no-cd]
certmanager action *version=just_certmanager_version:
  #!{{ shebang_strict }}
  
  {{ just_call }} _params "action" {{ action }} create destroy
  {{ just_call }} deploy _certmanager_{{ action }} {{ version}}

# Operate build kit deployment in k3s cluster: buildkit action=create|destroy|dryrun|dump|vals [values...]
[no-cd]
buildkit action *values:
  #!{{ shebang_strict }}
  
  {{ just_call }} _params "action" {{ action }} create destroy dryrun dump vals

  # calculate values paths
  values_str="{{ values }}"
  values=(${values_str})
  values_len=${#values[@]}

  value_paths_param=""
  if (( values_len > 0 )); then 
      real_paths=()
      for i in $(seq 0 $((values_len - 1))); do
          real_paths=($({{ just_call }} _relative_paths "deploy" "${values[i]}"))
      done
      printf -v value_paths_param '%s,' "${real_paths[@]}"
      value_paths_param="${value_paths_param%,}"
  fi 

  if [[ "${value_paths_param}" != "" ]]; then
      value_paths_param="-t values=${value_paths}"
  fi

  cd deploy

  if [[ "{{ action }}" == "create" ]]; then
      cue cmd apply -t namespace={{ just_builder_namespace }} ${value_paths_param}
  elif [[ "{{ action }}" == "dryrun" ]]; then
      cue cmd dryrun -t namespace={{ just_builder_namespace }} ${value_paths_param}
  elif [[ "{{ action }}" == "dump" ]]; then
      cue cmd dump -t namespace={{ just_builder_namespace }} ${value_paths_param}
  elif [[ "{{ action }}" == "vals" ]]; then
      cue cmd vals -t namespace={{ just_builder_namespace }} ${value_paths_param}
  else
      cue cmd delete -t namespace={{ just_builder_namespace }} ${value_paths_param}
  fi

# Show buildkit deployment info: info=shema|objects
[no-cd]
show info:
  #!{{ shebang_strict }}

  {{ just_call }} _params info {{ info }} schema objects
  {{ just_call }} deploy _show_{{ info }}

# Perform local builder configuration action=setup|info|use|replicas 
[no-cd]
builders action *params:
  #!{{ shebang_strict }}

  {{ just_call }} _params "action" {{ action }} setup info use replicas
  {{ just_call }} deploy _builders_{{ action }} {{ params }}

[no-cd]
_builders_setup *params:
  #!{{ shebang_strict }}

  num_replicas=$({{ just_call }} deploy builders replicas)
  for i in $(seq 0 $((num_replicas-1))); do
      docker buildx rm {{ just_builder_base_name }}-${i} || true
      docker buildx create --name {{ just_builder_base_name }}-${i} --driver remote \
        kube-pod://{{ just_builder_base_name }}-${i}?namespace={{ just_builder_namespace }}
  done

[no-cd]
_builders_info *dummy:
  @docker buildx ls

[no-cd]
_builders_use *params:
  #!{{ shebang_strict }}

  builder_num="{{ params }}"
  if [[ "${builder_num}" == "" ]]; then
      builder_num="0"
  fi

  docker buildx use {{ just_builder_base_name }}-${builder_num}

[no-cd]
_builders_replicas *params:
  @kubectl get statefulset {{ just_builder_base_name }}-ss -n {{ just_builder_namespace }} -o json | jq '.status.availableReplicas'

[no-cd]
_show_schema:
  #!{{ shebang_strict }}

  cd deploy
  cue def ./values -e '#Values' | sed '1,4d; $d; s/\t//'

[no-cd]
_show_objects:
  #!{{ shebang_strict }}

  cd deploy
  cue cmd ls

[no-cd]
_certmanager_create version: 
  #!{{ shebang_strict }}

  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.crds.yaml
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.yaml

[no-cd]
_certmanager_destroy version: 
  #!{{ shebang_strict }}

  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.yaml
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.crds.yaml