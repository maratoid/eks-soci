# Install binary dependencies with homebrew bundle with optional [upgrade]
brew upgrade="no":
    #!{{ shebang }}
  
    # check if 'upgrade' parameter is valid
    {{ just_call }} _params upgrade {{ upgrade }}

    # make sure brew bundle is installed
    echo "Checking 'brew bundle' ..."
    brew bundle --help > /dev/null 2>&1

    # install brew-bundled deps
    if [[ "{{ upgrade }}" = "yes" ]]; then
        brew bundle install -v --file {{ justfile_directory() }}/recipes/modules/deps/config/Brewfile
    else
        brew bundle install -v --no-upgrade --file {{ justfile_directory() }}/recipes/modules/deps/config/Brewfile
    fi