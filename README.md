# terraform-aws-network

## usage

```hcl
module "network" {
  source = "git::https://github.com/nalbam/terraform-aws-network.git"
  region = "ap-northeast-2"

  prefix = "dev"
}
```
