# code scaffold help page

# NAME

code scaffold [command] [subcommand] [params...]

# DESCRIPTION

Create scaffolding for a new just module with recipes

# EXAMPLE

```bash
just code scaffold deps bin
just code scaffold code lint dryrun path
```

# PARAMETERS

## Overview

* `command`       **Required**  
* `subcommand`    **Required**  
* `params..`      Optional   

## command

Top level command name to be created or added to.

## subcommand

Sub-command name to be created under `command`

## params

Array of `subcommand` parameters

# FILES

`command`, `subcommand` and help file templates are located under `recipes/modules/code/config`


# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)