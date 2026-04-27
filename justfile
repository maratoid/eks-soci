mod deploy 'recipes/modules/deploy/module.just'
mod cluster 'recipes/modules/cluster/module.just'
mod deps 'recipes/modules/deps/module.just'
mod code 'recipes/modules/code/module.just'

import 'recipes/utils/utils.just'
import 'recipes/utils/help.just'

[private]
default:
    @just --list