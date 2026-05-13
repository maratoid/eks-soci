# build hash help page

# NAME

build hash `tag`

# DESCRIPTION

Returns a consistent hash of container image tag to 0-indexed buildx builder number

# EXAMPLE

```bash
just build hash ghcr.io/maratoid/containerd-soci-builder:0.21.0
```

# PARAMETERS

## tag

Container image tag. I.e. `repo.com/user/image:X.X.X`

# FILES

Uses `consitenthash` utility from `build/consistenthash`

# Environment variables

## JUST_BUILDER_BASE_NAME

Base name for buildx builders, `buildkit`

## JUST_BUILDER_NAMESPACE

Namespace for buildkit manifests, `buildkit`

# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)