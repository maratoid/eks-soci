# set shell
set shell := ["/bin/bash", "-cu"]

# allow duplicate recipe names
set allow-duplicate-recipes := true
# load a dot-env file every time a recipe is run
set dotenv-load := true
# path to dot-env file to load
set dotenv-path := "recipes/.justenv"
# pass recipe arguments as positional arguments to commands. See https://github.com/casey/just?tab=readme-ov-file#positional-arguments
set positional-arguments := true

# reusable shebng line for recipes
shebang := if os() == "macos" { if arch() == "aarch64" {'''
    /opt/homebrew/opt/bash/bin/bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -x' || true```
'''} else {'''
    /usr/local/opt/bash/bin/bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -x' || true```
'''}} else {'''
    /usr/bin/env bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -x' || true```
'''}

shebang_strict := if os() == "macos" { if arch() == "aarch64" {'''
    /opt/homebrew/opt/bash/bin/bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -xeuo pipefail' || echo 'set -euo pipefail'```
'''} else {'''
    /usr/local/opt/bash/bin/bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -xeuo pipefail' || echo 'set -euo pipefail'```
'''}} else {'''
    /usr/bin/env bash
    ```[[ -n "${DEBUG:-}" ]] && echo 'set -xeuo pipefail' || echo 'set -euo pipefail'```
'''}
# reusable way to call just recipes from just recipes
just_call := "just --dotenv-path " + justfile_directory() / "recipes" / ".justenv"

# overrideables
just_tf_binary := env_var_or_default('JUST_TF_BINARY', 'tofu')
just_certmanager_version := env_var_or_default('JUST_CERTMANAGER_VERSION', '1.20.2')   
just_builder_base_name := env_var_or_default('JUST_BUILDER_BASE_NAME', 'buildkit')
just_builder_namespace := env_var_or_default('JUST_BUILDER_NAMESPACE', 'buildkit')
just_pass_gh_token := env_var_or_default('JUST_PASS_GH_TOKEN', 'yes')