# cluster destroy help page

# NAME

cluster destroy `[terraform/tofu destroy parameters ...]`

# DESCRIPTION

Destroy multipass-based kubernetes cluster.

# EXAMPLE

```bash
TF_VAR_worker_count=5 just cluster destroy -auto-approve
```

# PARAMETERS

See `tofu destroy --help` and `terraform destroy --help`

# FILES

Terraform/OpenTofu files located at `terraform/`

# Environment variables

## JUST_TF_BINARY

Terraform binary to use. `tofu`

## terraform

See https://developer.hashicorp.com/terraform/cli/config/environment-variables


# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)