import '../../utils/utils.just'
import './scaffold.just'

# output list of module commands when 'just code' is run
[private]
default:
    @just --justfile {{ justfile() }} --list code