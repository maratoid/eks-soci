mod build 'recipes/modules/build/module.just'
mod builders 'recipes/modules/builders/module.just'
mod deploy 'recipes/modules/deploy/module.just'
mod cluster 'recipes/modules/cluster/module.just'
mod code 'recipes/modules/code/module.just'

import 'recipes/utils/utils.just'
import 'recipes/utils/help.just'

[private]
default:
    @just --list