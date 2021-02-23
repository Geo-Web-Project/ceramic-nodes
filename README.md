## Terraform Setup

```
terraform init
```

## Deploy

1. See plan

```
terraform plan \
  -var "do_token=${DO_PAT}" \
  -var "pvt_key=$HOME/.ssh/terraform"
```

2. Apply plan

```
terraform apply \
  -var "do_token=${DO_PAT}" \
  -var "pvt_key=$HOME/.ssh/terraform"
```

## Install Ceramic

```
git clone https://github.com/ceramicnetwork/js-ceramic.git
npm run bootstrap
npm run build
```
