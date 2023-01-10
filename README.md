# devops-stack-module-argocd

A [DevOps Stack](https://devops-stack.io) module to finalize [ArgoCD](https://argoproj.github.io/cd/).

While the `argocd-helm` module deploys a bootstrap ArgoCD, this module allows to finalize its installation and should be called at the end of all DevOps Stack modules.

## Usage

```hcl
module "argocd" {
  source = "git::https://github.com/camptocamp/devops-stack-module-argocd.git/"

  base_domain              = "example.com"
  cluster_name             = "my-cluster"
  cluster_issuer           = "letsencrypt-prod"
  admin_enabled            = "true"
  namespace                = local.argocd_namespace
  accounts_pipeline_tokens = module.argocd_bootstrap[0].argocd_accounts_pipeline_tokens
  server_secretkey         = module.argocd_bootstrap[0].argocd_server_secretkey


dependency_ids = {
    prometheus   = module.prometheus-stack[0].id
    cert-manager = module.cert-manager[0].id
  }
}
```

Once module is applied and argocd Application synched, service becomes available at `argocd.apps.my-cluster.example.com`
