# set shell
set shell := ["/bin/zsh", "-cu"]

# allow duplicate recipe names
set allow-duplicate-recipes := true
# load a dot-env file every time a recipe is run
set dotenv-load := true
# path to dot-env file to load
set dotenv-path := "recipes/.justenv"
# pass recipe arguments as positional arguments to commands. See https://github.com/casey/just?tab=readme-ov-file#positional-arguments
set positional-arguments := true

# reusable shebng line for recipes
shebang := '''
    /usr/bin/env zsh
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -x' || true```
'''

shebang_strict := '''
    /usr/bin/env zsh
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -xeuo pipefail' || echo 'set -euo pipefail'```
'''
# reusable way to call just recipes from just recipes
just_call := "just --dotenv-path " + justfile_directory() / "recipes" / ".justenv"

# overrideables
just_tf_binary := env_var_or_default('JUST_TF_BINARY', 'tofu')
just_certmanager_version := env_var_or_default('JUST_CERTMANAGER_VERSION', '1.20.2')   
just_builder_base_name := env_var_or_default('JUST_BUILDER_BASE_NAME', 'buildkit')
just_builder_namespace := env_var_or_default('JUST_BUILDER_NAMESPACE', 'buildkit')