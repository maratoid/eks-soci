# create a k3s cluster with terraform and multipass, passing terraform [params]
[no-cd]
create *params="": (_cmd "apply" params)

# destroy k3s cluster, passing terraform [params]
[no-cd]
destroy *params="": (_cmd "destroy" params)

[no-cd]
_cmd command *params: 
  #!{{ shebang_strict }}

  params_str="{{ params }}"
  params=(${params_str})
  {{ just_tf_binary }} -chdir="{{ justfile_directory() }}/terraform" {{ command }} "${params[@]}"