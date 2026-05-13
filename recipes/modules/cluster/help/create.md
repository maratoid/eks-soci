# cluster create help page

# NAME

cluster create `[terraform/tofu apply parameters ...]`

# DESCRIPTION

Create multipass-based kubernetes cluster.

# EXAMPLE

```bash
TF_VAR_worker_count=5 just cluster create -auto-approve
```

# PARAMETERS

See `tofu apply --help` and `terraform apply --help`

# FILES

Terraform/OpenTofu files located at `terraform/`

# Environment variables

## JUST_TF_BINARY

Terraform binary to use. `tofu`

## terraform

See https://developer.hashicorp.com/terraform/cli/config/environment-variables


# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)