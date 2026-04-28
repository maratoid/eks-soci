import '../../utils/utils.just'
import './brew.just'

[private]
default:
    @just --justfile {{ justfile() }} --list deps