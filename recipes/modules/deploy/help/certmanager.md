# deploy certmanager help page

# NAME

deploy certmanager `action` `[certmanager version]`

# DESCRIPTION

Manage cert-manager deployment in multipass-based kubernetes cluster.

# EXAMPLE

```bash
just deploy certmanager create 
just deploy certmanager create 1.20.2
just deploy certmanager destroy 
just deploy certmanager destroy 1.20.2
```

# PARAMETERS

## action

* `create` - create cert manager deployment
* `destroy` - destroy cert manager deployment

## certmanager version

cert manager version. Defaults to value of `JUST_CERTMANAGER_VERSION`

# FILES

None

# Environment variables

## JUST_CERTMANAGER_VERSION

Cert manager default version. `1.20.2`

# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)