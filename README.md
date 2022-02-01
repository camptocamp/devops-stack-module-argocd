# devops-stack-module-argocd

A [DevOps Stack](https://devops-stack.io) module to finalize [ArgoCD](https://argoproj.github.io/cd/).

While the `argocd-helm` module deploys a bootstrap ArgoCD, this module allows to finalize its installation and should be called at the end of all DevOps Stack modules.


## Usage

```hcl
module "argocd" {
  source = "git::https://github.com/camptocamp/devops-stack-module-argocd.git//modules"

  cluster_info   = module.cluster.info
  oidc           = module.oidc.oidc
  argocd         = {
    server_secretkey = module.cluster.argocd_server_secretkey
    accounts_pipeline_tokens = module.cluster.argocd_accounts_pipeline_tokens
    server_admin_password = module.cluster.argocd_server_admin_password
    domain = module.cluster.argocd_domain
    admin_enabled = true
  }
  cluster_issuer = "letsencrypt-prod"

  depends_on = [ module.cert-manager, module.monitoring ]
}
```

