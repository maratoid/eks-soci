# deploy buildkit help page

# NAME

deploy buildkit `action` `[values file ...]`

# DESCRIPTION

Perform `action` on buildkit deployment.

# EXAMPLE

```bash
just deploy buildkit rollout
just deploy buildkit create 
just deploy buildkit create values/values.yaml
just deploy buildkit destroy values/values.yaml
just deploy buildkit dryrun values/values.yaml
just deploy buildkit dryrun
just deploy buildkit dump
just deploy buildkit dump values/values.yaml
just deploy buildkit vals
just deploy buildkit vals values/values.yaml
just deploy buildkit schema
just deploy buildkit objects
just deploy buildkit objects values/values.yaml
```

# PARAMETERS

## action

Action to perform:

### create

Create buildkit deployment, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead. 

### destroy

Delete buildkit deployment, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead.

### dryrun

Dryrun-create buildkit deployment, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead.

### dump

Dump buildkit deployment manifests, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead.

### vals

Dump buildkit deployment values, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead.

### schema

Dump buildkit deployment values schema.

### objects

List buildkit deployment objects, using optional `[values file ...]` files.  
Each values file can override a base value once.  
Overriding deployment namespace through values files is not supported, use `JUST_BUILDER_NAMESPACE` instead.

### rollout

Force builder stateful set rollout.

# FILES

CueLang files used for deployment manifest generation are under `deploy/` directory.

# Environment variables

## JUST_BUILDER_BASE_NAME

Base name for buildx builders, `buildkit`

## JUST_BUILDER_NAMESPACE

Namespace for buildkit manifests, `buildkit`


# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)