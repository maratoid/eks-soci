import '../../utils/utils.just'
import './recipes.just'

[private]
default:
  @just --justfile {{ justfile() }} --list cluster