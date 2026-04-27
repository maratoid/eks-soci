# Operate certmanager deployment in k3s cluster: create|destroy [version]
[no-cd]
certmanager *params:
  #!{{ shebang_strict }}

  # calculate parameters
  params_str="{{ params }}"
  params=(${params_str})
  params_len=${#params[@]}

  certmanager_cmd="create"
  (( params_len > 0 )) && certmanager_cmd="${params[0]}"
  
  {{ just_call }} _params "operation" ${certmanager_cmd} create destroy
  {{ just_call }} deploy _certmanager_${certmanager_cmd} ${params[@]:1}

# Operate build kit deployment in k3s cluster: buildkit create|destroy [namespace] [values...]
[no-cd]
buildkit *params:
  #!{{ shebang_strict }}

  # calculate parameters
  params_str="{{ params }}"
  params=(${params_str})
  params_len=${#params[@]}

  buildkit_cmd="create"
  (( params_len > 0 )) && buildkit_cmd="${params[0]}"
  
  {{ just_call }} _params "operation" ${buildkit_cmd} create destroy dryrun dump vals
  {{ just_call }} deploy _buildkit ${buildkit_cmd} ${params[@]:1}

# Show buildkit deployment info: info=shema|objects
[no-cd]
show info:
  #!{{ shebang_strict }}

  {{ just_call }} _params info {{ info }} schema objects
  {{ just_call }} deploy _show_{{ info }}

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
_certmanager_create *version=just_certmanager_version: 
  #!{{ shebang_strict }}

  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.crds.yaml
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.yaml

[no-cd]
_certmanager_destroy *version=just_certmanager_version: 
  #!{{ shebang_strict }}

  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.yaml
  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/{{ version }}/cert-manager.crds.yaml

[no-cd]
_buildkit cmd *params: 
  #!{{ shebang_strict }}

  # calculate parameters
  params_str="{{ params }}"
  params=(${params_str})
  params_len=${#params[@]}

  namespace_param="-t namespace=buildkit"
  (( params_len > 0 )) && namespace_param="-t namespace=${params[0]}"
  
  value_paths_param=""
  if (( params_len > 1 )); then 
      real_paths=()
      for i in $(seq 1 $((params_len - 1))); do
          real_paths=($({{ just_call }} _relative_paths "deploy" "${params[i]}"))
      done
      printf -v value_paths_param '%s,' "${real_paths[@]}"
      value_paths_param="${value_paths_param%,}"
  fi 

  if [[ "${value_paths_param}" != "" ]]; then
      value_paths_param="-t values=${value_paths}"
  fi

  cd deploy

  if [[ "${cmd}" == "create" ]]; then
      cue cmd apply ${namespace_param} ${value_paths_param}
  elif [[ "${cmd}" == "dryrun" ]]; then
      cue cmd dryrun ${namespace_param} ${value_paths_param}
  elif [[ "${cmd}" == "dump" ]]; then
      cue cmd dump ${namespace_param} ${value_paths_param}
  elif [[ "${cmd}" == "vals" ]]; then
      cue cmd vals ${namespace_param} ${value_paths_param}
  else
      ecue cmd delete ${namespace_param} ${value_paths_param}
  fi
  