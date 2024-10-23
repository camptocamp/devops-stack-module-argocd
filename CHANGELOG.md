# Changelog

## [7.1.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v7.1.0...v7.1.1) (2024-10-23)


### Bug Fixes

* **dashboards:** add release in file name to avoid duplicates ([#138](https://github.com/camptocamp/devops-stack-module-argocd/issues/138)) ([e8c0d9b](https://github.com/camptocamp/devops-stack-module-argocd/commit/e8c0d9b7217537def7de19752ce7d469be70d464))

## [7.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v7.0.0...v7.1.0) (2024-10-11)


### Features

* **chart:** minor update of dependencies on argocd chart ([#132](https://github.com/camptocamp/devops-stack-module-argocd/issues/132)) ([635a11c](https://github.com/camptocamp/devops-stack-module-argocd/commit/635a11c4f6e3c10c78921f9d7c552c976f7b0455))


### Bug Fixes

* grafana panels uses angular deprecated plugin ([#135](https://github.com/camptocamp/devops-stack-module-argocd/issues/135)) ([60bdfea](https://github.com/camptocamp/devops-stack-module-argocd/commit/60bdfead93bf94bcd12994d021b4d60291e5ec86))

## [7.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v6.3.0...v7.0.0) (2024-10-09)


### ⚠ BREAKING CHANGES

* point the Argo CD provider to the new repository ([#133](https://github.com/camptocamp/devops-stack-module-argocd/issues/133))

### Features

* point the Argo CD provider to the new repository ([#133](https://github.com/camptocamp/devops-stack-module-argocd/issues/133)) ([86616d9](https://github.com/camptocamp/devops-stack-module-argocd/commit/86616d9f49b6a73eb521bac27c052b0d2a38b798))

### Migrate provider source `oboukili` -> `argoproj-labs`

We've tested the procedure found [here](https://github.com/argoproj-labs/terraform-provider-argocd?tab=readme-ov-file#migrate-provider-source-oboukili---argoproj-labs) and we think the order of the steps is not exactly right. This is the procedure we recommend (**note that this should be run manually on your machine and not on a CI/CD workflow**):

1. First, make sure you are already using version 6.2.0 of the `oboukili/argocd` provider.

1. Then, check which modules you have that are using the `oboukili/argocd` provider.

```shell
$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/helm] 2.15.0
├── (...)
└── provider[registry.terraform.io/oboukili/argocd] 6.2.0

Providers required by state:

    (...)

    provider[registry.terraform.io/oboukili/argocd]

    provider[registry.terraform.io/hashicorp/helm]
```

3. Afterwards, proceed to point **ALL*  the DevOps Stack modules to the versions that have changed the source on their respective requirements. In case you have other personal modules that also declare `oboukili/argocd` as a requirement, you will also need to update them.

4. Also update the required providers on your root module. If you've followed our examples, you should find that configuration on the `terraform.tf` file in the root folder.

5. Execute the migration  via `terraform state replace-provider`:

```bash
$ terraform state replace-provider registry.terraform.io/oboukili/argocd registry.terraform.io/argoproj-labs/argocd
Terraform will perform the following actions:

  ~ Updating provider:
    - registry.terraform.io/oboukili/argocd
    + registry.terraform.io/argoproj-labs/argocd

Changing 13 resources:

  module.argocd_bootstrap.argocd_project.devops_stack_applications
  module.secrets.module.secrets.argocd_application.this
  module.metrics-server.argocd_application.this
  module.efs.argocd_application.this
  module.loki-stack.module.loki-stack.argocd_application.this
  module.thanos.module.thanos.argocd_application.this
  module.cert-manager.module.cert-manager.argocd_application.this
  module.kube-prometheus-stack.module.kube-prometheus-stack.argocd_application.this
  module.argocd.argocd_application.this
  module.traefik.module.traefik.module.traefik.argocd_application.this
  module.ebs.argocd_application.this
  module.helloworld_apps.argocd_application.this
  module.helloworld_apps.argocd_project.this

Do you want to make these changes?
Only 'yes' will be accepted to continue.

Enter a value: yes

Successfully replaced provider for 13 resources.
```

6. Perform a `terraform init -upgrade` to upgrade your local `.terraform` folder.

7. Run a `terraform plan` or `terraform apply` and you should see that everything is OK and that no changes are necessary. 

## [6.3.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v6.2.0...v6.3.0) (2024-08-29)


### Features

* **chart:** minor update of dependencies on argocd chart ([#127](https://github.com/camptocamp/devops-stack-module-argocd/issues/127)) ([476c9d7](https://github.com/camptocamp/devops-stack-module-argocd/commit/476c9d78b90bd700044a656a7f4a9759532c243b))

## [6.2.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v6.1.0...v6.2.0) (2024-08-29)


### Features

* **chart:** patch update of dependencies on argocd chart ([#126](https://github.com/camptocamp/devops-stack-module-argocd/issues/126)) ([1a6621f](https://github.com/camptocamp/devops-stack-module-argocd/commit/1a6621fc905d64243f15e903e9266fb7ee9e0c2c))

## [6.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v6.0.0...v6.1.0) (2024-08-20)


### Features

* **chart:** patch update of dependencies on argocd chart ([#124](https://github.com/camptocamp/devops-stack-module-argocd/issues/124)) ([ad9dd42](https://github.com/camptocamp/devops-stack-module-argocd/commit/ad9dd4210f314f576b79d79f515eb095be935c4d))

## [6.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.5.0...v6.0.0) (2024-08-15)


### ⚠ BREAKING CHANGES

* **chart:** minor update of dependencies on argocd chart ([#119](https://github.com/camptocamp/devops-stack-module-argocd/issues/119))
  - the minimum Kubernetes version is now 1.25;
  - Argo CD is now upgraded to version 2.12.0; **please check the [upgrade guide](https://argo-cd.readthedocs.io/en/latest/operator-manual/upgrading/2.11-2.12/) to see if you are affected by any of the changes**;

### Features

* **chart:** minor update of dependencies on argocd chart ([#119](https://github.com/camptocamp/devops-stack-module-argocd/issues/119)) ([1cb0c92](https://github.com/camptocamp/devops-stack-module-argocd/commit/1cb0c92bcbf96529dad2aa270bfc2b26699e9b18))

## [5.5.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.4.0...v5.5.0) (2024-08-15)


### Features

* **chart:** patch update of dependencies on argocd chart ([#117](https://github.com/camptocamp/devops-stack-module-argocd/issues/117)) ([8c93fda](https://github.com/camptocamp/devops-stack-module-argocd/commit/8c93fda86825a7a1e9a32a8f03b887260637570d))

## [5.4.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.3.0...v5.4.0) (2024-08-06)


### Features

* update prometheus rule to be more flexible ([#114](https://github.com/camptocamp/devops-stack-module-argocd/issues/114)) ([5f80f8a](https://github.com/camptocamp/devops-stack-module-argocd/commit/5f80f8a32b011454044a3bab2d603f1f549a6805))

## [5.3.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.2.0...v5.3.0) (2024-07-10)


### Features

* **chart:** minor update of dependencies on argocd chart ([#113](https://github.com/camptocamp/devops-stack-module-argocd/issues/113)) ([67e4086](https://github.com/camptocamp/devops-stack-module-argocd/commit/67e408608c5472095f2e0273a204f24064db3832))

## [5.2.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.1.0...v5.2.0) (2024-06-18)


### Features

* **chart:** patch update of dependencies on argocd chart ([#110](https://github.com/camptocamp/devops-stack-module-argocd/issues/110)) ([2fba6b6](https://github.com/camptocamp/devops-stack-module-argocd/commit/2fba6b65b5a5c334ede84a639a97fc1e529b1a79))

## [5.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v5.0.0...v5.1.0) (2024-06-11)


### Features

* **chart:** minor update of dependencies on argocd chart ([#108](https://github.com/camptocamp/devops-stack-module-argocd/issues/108)) ([ae51f89](https://github.com/camptocamp/devops-stack-module-argocd/commit/ae51f896b8abcaba1513cafacd60df690e20ea21))

## [5.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.5.0...v5.0.0) (2024-06-11)


### ⚠ BREAKING CHANGES

* **chart:** major update of dependencies on argocd chart:
  * The upstream chart has removed multiple configurations that should not affect you unless you overload any of the following attributes using the `helm_values` variable:
    * deprecated component options `logLevel` and `logFormat`
    * deprecated component arguments `<components>.args.<feature>` that were replaced with `configs.params`
    * deprecated configuration `server.config` that was replaced with `configs.cm`
    * deprecated configuration `server.rbacConfig` that was replaced with `configs.rbac`


### Features

* **chart:** major update of dependencies on argocd chart ([52543df](https://github.com/camptocamp/devops-stack-module-argocd/commit/52543df692e21fee2cd772ca47282d166f0fdfae))
* modify the Helm values to support new chart version ([a2127c9](https://github.com/camptocamp/devops-stack-module-argocd/commit/a2127c94e84282b8138282b6c365ab6b37a0a6b0))


### Bug Fixes

* add domain value ([fae7776](https://github.com/camptocamp/devops-stack-module-argocd/commit/fae7776f1b85e7bac9424840d2ad2234e2599dc9))
* fix typo that prevented OIDC configuration apply ([e5bec3f](https://github.com/camptocamp/devops-stack-module-argocd/commit/e5bec3f9a97ecc650f7ddd491990ad4182d79c60))

## [4.5.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.4.1...v4.5.0) (2024-05-29)


### Features

* add variables to set resource requests/limits on plugins ([#104](https://github.com/camptocamp/devops-stack-module-argocd/issues/104)) ([9f6789e](https://github.com/camptocamp/devops-stack-module-argocd/commit/9f6789ec95fc9cd8841606f45b6f94d3ecf1dfb5))

## [4.4.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.4.0...v4.4.1) (2024-04-16)


### Bug Fixes

* adjust the resources and remove default limits ([6818519](https://github.com/camptocamp/devops-stack-module-argocd/commit/6818519d86d381edba3efbff69915899e0028ac5))
* **aks:** remove deprecated label from repo server service account for workload id ([cc58a8a](https://github.com/camptocamp/devops-stack-module-argocd/commit/cc58a8abe4b6949535d9cf1e24cb0df98c5e7311))

## [4.4.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.3.0...v4.4.0) (2024-03-14)


### Features

* **plugins:** set loglevel to warning on helmfile and kustomize ([71c1c50](https://github.com/camptocamp/devops-stack-module-argocd/commit/71c1c506cbd35620400a57eed8d88795a9f84ca8))

## [4.3.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.2.0...v4.3.0) (2024-03-01)


### Features

* make the dashboard deployment dynamic ([caa397b](https://github.com/camptocamp/devops-stack-module-argocd/commit/caa397bee0b5f207e8fdd4e585c997ee2df91dc9))


### Bug Fixes

* delete legacy OpenShift template ([533db1f](https://github.com/camptocamp/devops-stack-module-argocd/commit/533db1f9d9c0cf16835f0bdd59fe8c90e187666b))
* remove legacy ingress annotations ([ae712db](https://github.com/camptocamp/devops-stack-module-argocd/commit/ae712db9ebbac8cc9fbf1fca5fc4a585b5d142ab))

## [4.2.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.1.0...v4.2.0) (2024-02-23)


### Features

* **chart:** minor update of dependencies on argocd chart ([#79](https://github.com/camptocamp/devops-stack-module-argocd/issues/79)) ([f29d7be](https://github.com/camptocamp/devops-stack-module-argocd/commit/f29d7be9652f7c348e9d13ccfcbf703ebe7081bb))

## [4.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v4.0.0...v4.1.0) (2024-02-23)


### Features

* add a subdomain variable ([3ec9b23](https://github.com/camptocamp/devops-stack-module-argocd/commit/3ec9b2372be391ea6b90c3ab7a77bce92f5ddaa8))


### Bug Fixes

* make subdomain variable non-nullable ([45fbff4](https://github.com/camptocamp/devops-stack-module-argocd/commit/45fbff438b18c6b93d51b3034445d05e0b2f3f5f))
* remove annotation for the redirection middleware ([94449d0](https://github.com/camptocamp/devops-stack-module-argocd/commit/94449d075dbc5f9760f45149dcd67319292f06ff))

## [4.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.5.2...v4.0.0) (2024-01-19)


### ⚠ BREAKING CHANGES

* remove the ArgoCD namespace variable
* remove the namespace variable
* hardcode the release name to remove the destination cluster

### Bug Fixes

* hardcode the release name to remove the destination cluster ([7076e8b](https://github.com/camptocamp/devops-stack-module-argocd/commit/7076e8b7783c0b6c5884980f905d1ad576bc1331))
* remove the ArgoCD namespace variable ([5dd52e9](https://github.com/camptocamp/devops-stack-module-argocd/commit/5dd52e9b47b23baa857af13730f0b490af53533e))
* remove the namespace variable ([ee1eeed](https://github.com/camptocamp/devops-stack-module-argocd/commit/ee1eeed6d6a570be145828116b5f53220e524821))

## [3.5.2](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.5.1...v3.5.2) (2023-12-21)


### Bug Fixes

* add ServiceMonitors to fix missing metrics on Prometheus ([c48afda](https://github.com/camptocamp/devops-stack-module-argocd/commit/c48afda54c2e667354e01c6fb14252e2caccfb5c))
* increase default resources for the app controller and repo server ([90d9c50](https://github.com/camptocamp/devops-stack-module-argocd/commit/90d9c509d6c9a1bee1905a9d0c4200fba022b9bd))

## [3.5.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.5.0...v3.5.1) (2023-11-13)


### Bug Fixes

* **bootstrap:** fix the validation of `argocd_projects` when nothing is passed ([#84](https://github.com/camptocamp/devops-stack-module-argocd/issues/84)) ([9dd6b96](https://github.com/camptocamp/devops-stack-module-argocd/commit/9dd6b967b23c9acc36e570b69aefa724a30e4fa8))

## [3.5.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.4.1...v3.5.0) (2023-11-10)


### Features

* add HA configuration and resource requests/limits ([ad6e736](https://github.com/camptocamp/devops-stack-module-argocd/commit/ad6e7367ead43c7752f24a33a54875a173a1fd2f))
* add standard variables and variable to add labels to Argo CD app ([113d13c](https://github.com/camptocamp/devops-stack-module-argocd/commit/113d13c1f783244b5a8683d9ef33ad24ffd4c1e2))
* add variable to allow the use of the unified AppProject ([5811d53](https://github.com/camptocamp/devops-stack-module-argocd/commit/5811d53412277dcba92239c5953900e3819d101e))
* add way to create a unified AppProject to use by all the modules ([6ffd06b](https://github.com/camptocamp/devops-stack-module-argocd/commit/6ffd06b6894bda589e006ee13564d36f8322bf71))


### Bug Fixes

* use the cluster issuer created on all cert-manager variants ([53d5286](https://github.com/camptocamp/devops-stack-module-argocd/commit/53d52865636616ee729408f37532a98c8b81dfd4))

## [3.4.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.4.0...v3.4.1) (2023-11-10)


### Bug Fixes

* fix the activation of the web-terminal on Argo CD ([#80](https://github.com/camptocamp/devops-stack-module-argocd/issues/80)) ([a23fd8b](https://github.com/camptocamp/devops-stack-module-argocd/commit/a23fd8bac44ce55d226b0ee00269dd1d0871b37c))

## [3.4.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.3.0...v3.4.0) (2023-09-08)


### Features

* **chart:** minor update of dependencies on argocd chart ([#74](https://github.com/camptocamp/devops-stack-module-argocd/issues/74)) ([bd8d070](https://github.com/camptocamp/devops-stack-module-argocd/commit/bd8d070d92ddbea8f9db8c6f8fb226bebcf047ab))

## [3.3.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.2.0...v3.3.0) (2023-08-28)


### 📝 NOTES

* The underlying chart upgrades Argo CD image from 2.8.0 to 2.8.1.

### Features

* **chart:** patch update of dependencies on argocd chart ([#73](https://github.com/camptocamp/devops-stack-module-argocd/issues/73)) ([68e3f09](https://github.com/camptocamp/devops-stack-module-argocd/commit/68e3f0927fcf4deed093a8c34bbfbd9d2d706b89))

## [3.2.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.1.3...v3.2.0) (2023-08-18)


### Features

* **chart:** minor update of dependencies on argocd chart ([#67](https://github.com/camptocamp/devops-stack-module-argocd/issues/67)) ([bdeeea4](https://github.com/camptocamp/devops-stack-module-argocd/commit/bdeeea4f96c9bb9457b863df8a5c7b615e8a35af))

## [3.1.3](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.1.2...v3.1.3) (2023-08-11)


### Bug Fixes

* readd support to deactivate auto-sync which was broken by [#57](https://github.com/camptocamp/devops-stack-module-argocd/issues/57) ([b6cc545](https://github.com/camptocamp/devops-stack-module-argocd/commit/b6cc5458f4c7b70cc07323a1f34bd0ea4552c18c))

## [3.1.2](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.1.1...v3.1.2) (2023-07-19)


### Bug Fixes

* change default to null to not remove the default known_hosts ([#62](https://github.com/camptocamp/devops-stack-module-argocd/issues/62)) ([08c39c4](https://github.com/camptocamp/devops-stack-module-argocd/commit/08c39c47d242455c681d0b43b74695a4edf4388f))

## [3.1.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.1.0...v3.1.1) (2023-07-12)


### Bug Fixes

* add default value to the rbac variable ([#60](https://github.com/camptocamp/devops-stack-module-argocd/issues/60)) ([31dcef0](https://github.com/camptocamp/devops-stack-module-argocd/commit/31dcef0d9ee40e711852c7feb70442474f11380e))

## [3.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v3.0.0...v3.1.0) (2023-07-11)


### Features

* add validation to the helmfile_cmp variable ([8fc31b7](https://github.com/camptocamp/devops-stack-module-argocd/commit/8fc31b7175bb2bd62b6b405bd002453ad8fb2f8a))
* upgrade Argo CD chart ([d99bf8b](https://github.com/camptocamp/devops-stack-module-argocd/commit/d99bf8bdc14a7895fd76b8c64454b32b083f3b3f))
* variabilize env variables + version for the helmfile-cmp plugin ([8fc31b7](https://github.com/camptocamp/devops-stack-module-argocd/commit/8fc31b7175bb2bd62b6b405bd002453ad8fb2f8a))
* variabilize RBAC, SSH known hosts and web terminal activation ([c8d6440](https://github.com/camptocamp/devops-stack-module-argocd/commit/c8d64406316774c9d78313894b56d403b9f66b35))


### Bug Fixes

* get Argo CD version from Chart.yaml ([51c0786](https://github.com/camptocamp/devops-stack-module-argocd/commit/51c078663353d44294c4a42b4287d7d613125f89))

## [3.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v2.1.0...v3.0.0) (2023-07-10)


### ⚠ BREAKING CHANGES

* add support to oboukili/argocd >= v5 ([#57](https://github.com/camptocamp/devops-stack-module-argocd/issues/57))

### Features

* add support to oboukili/argocd &gt;= v5 ([#57](https://github.com/camptocamp/devops-stack-module-argocd/issues/57)) ([886689b](https://github.com/camptocamp/devops-stack-module-argocd/commit/886689b8fb9132c8a6f27896a24eee4b38b1c38e))

## [2.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v2.0.0...v2.1.0) (2023-06-29)


### Features

* upgrade helmfile cmp with latest helm-sops ([#54](https://github.com/camptocamp/devops-stack-module-argocd/issues/54)) ([fa33d7c](https://github.com/camptocamp/devops-stack-module-argocd/commit/fa33d7c5a5e8b0c652599bc80c5ad71530becc35))

## [2.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.1.2...v2.0.0) (2023-06-09)


### ⚠ BREAKING CHANGES

* add helmfile-sops custom plugin installation ([#51](https://github.com/camptocamp/devops-stack-module-argocd/issues/51))

### Features

* add helmfile-sops custom plugin installation ([#51](https://github.com/camptocamp/devops-stack-module-argocd/issues/51)) ([56cc3b4](https://github.com/camptocamp/devops-stack-module-argocd/commit/56cc3b4581421b420ffcccc9d6d301bfdb11a174))

## [1.1.2](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.1.1...v1.1.2) (2023-06-02)


### Bug Fixes

* mount ca cert also for letsencrypt-staging and parameterize secret key ([#49](https://github.com/camptocamp/devops-stack-module-argocd/issues/49)) ([06a180d](https://github.com/camptocamp/devops-stack-module-argocd/commit/06a180d22d4569f0eac9d4818c6afc868b6e3e08))

## [1.1.1](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.1.0...v1.1.1) (2023-05-25)


### Documentation

* add usage and troubleshooting sections ([#45](https://github.com/camptocamp/devops-stack-module-argocd/issues/45)) ([c23fd1b](https://github.com/camptocamp/devops-stack-module-argocd/commit/c23fd1b451c3cbd42385f54e7e2f66833d8f71cd))

## [1.1.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0...v1.1.0) (2023-04-13)


### Features

* support extra accounts token generation ([#42](https://github.com/camptocamp/devops-stack-module-argocd/issues/42)) ([762ce3e](https://github.com/camptocamp/devops-stack-module-argocd/commit/762ce3ea2327ac4804aad04fdb36afe63595355a))

## [1.0.0](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.9...v1.0.0) (2023-04-06)


### Features

* upgrade argocd helm chart 5.27.1 ([#37](https://github.com/camptocamp/devops-stack-module-argocd/issues/37)) ([e2c5f0c](https://github.com/camptocamp/devops-stack-module-argocd/commit/e2c5f0c818daa6024f2504ee38a48d6148d4eac7))

## [1.0.0-alpha.9](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.8...v1.0.0-alpha.9) (2023-03-27)


### Documentation

* add docs structure and PR template ([#39](https://github.com/camptocamp/devops-stack-module-argocd/issues/39)) ([7dc0991](https://github.com/camptocamp/devops-stack-module-argocd/commit/7dc0991af84cc3386943535859aed6a9f66d5f68))

## [1.0.0-alpha.8](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.7...v1.0.0-alpha.8) (2023-03-22)


### Features

* add new default administrator group ([#36](https://github.com/camptocamp/devops-stack-module-argocd/issues/36)) ([4b66416](https://github.com/camptocamp/devops-stack-module-argocd/commit/4b664163745eaca9d5701e43eb1e4b669f3e939e))

## [1.0.0-alpha.7](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.6...v1.0.0-alpha.7) (2023-03-10)


### Bug Fixes

* **terraform:** change to looser versions constraints as per best practices ([#34](https://github.com/camptocamp/devops-stack-module-argocd/issues/34)) ([857f793](https://github.com/camptocamp/devops-stack-module-argocd/commit/857f7932db65947af6e76d52b2cb90b4d3085eca))

## [1.0.0-alpha.6](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.5...v1.0.0-alpha.6) (2023-02-07)


### Bug Fixes

* **bootstrap:** get chart version from Chart.lock ([#31](https://github.com/camptocamp/devops-stack-module-argocd/issues/31)) ([0a449a9](https://github.com/camptocamp/devops-stack-module-argocd/commit/0a449a921784afa74fa67294cd62f66478ab6c3e))


### Miscellaneous Chores

* release 1.0.0-alpha.6 ([#33](https://github.com/camptocamp/devops-stack-module-argocd/issues/33)) ([5ea7e9c](https://github.com/camptocamp/devops-stack-module-argocd/commit/5ea7e9c4b531bb41ca46f7423c58f70b9e1b84fa))

## [1.0.0-alpha.5](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.4...v1.0.0-alpha.5) (2023-01-30)


### ⚠ BREAKING CHANGES

* refact main argocd module ([#28](https://github.com/camptocamp/devops-stack-module-argocd/issues/28))

### Features

* refact main argocd module ([#28](https://github.com/camptocamp/devops-stack-module-argocd/issues/28)) ([62ddac7](https://github.com/camptocamp/devops-stack-module-argocd/commit/62ddac7319142e3f74faf346bd5bbaf930dab615))


### Miscellaneous Chores

* release 1.0.0-alpha.5 ([#30](https://github.com/camptocamp/devops-stack-module-argocd/issues/30)) ([fe79dbe](https://github.com/camptocamp/devops-stack-module-argocd/commit/fe79dbe2239e2a66e5f0bea297c6a31bb003f157))

## [1.0.0-alpha.4](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.3...v1.0.0-alpha.4) (2022-12-21)


### Features

* **chart:** update Argo CD chart to v5.14.1 ([#22](https://github.com/camptocamp/devops-stack-module-argocd/issues/22)) ([ebd91b0](https://github.com/camptocamp/devops-stack-module-argocd/commit/ebd91b0e283ab35c705fa6e135c26f2ef55cc3df))

## [1.0.0-alpha.3](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.2...v1.0.0-alpha.3) (2022-12-20)


### Features

* **wait:** add dependency to var app_autosync ([#20](https://github.com/camptocamp/devops-stack-module-argocd/issues/20)) ([bc53496](https://github.com/camptocamp/devops-stack-module-argocd/commit/bc53496e36aa3f2364a8011b3823a3712539c299))

## [1.0.0-alpha.2](https://github.com/camptocamp/devops-stack-module-argocd/compare/v1.0.0-alpha.1...v1.0.0-alpha.2) (2022-12-16)


### Features

* introduce a variable to set auto sync on the Argo CD application resource ([#18](https://github.com/camptocamp/devops-stack-module-argocd/issues/18)) ([b8b60e6](https://github.com/camptocamp/devops-stack-module-argocd/commit/b8b60e67a9f4dd10fa49efc01bdf22c1f8df746e))

## 1.0.0-alpha.1 (2022-11-18)


### ⚠ BREAKING CHANGES

* separate variables for bootstrap module
* **oidc:** pass argocd specific oidc configuration as variable
* disable Dex by default
* **oidc:** use a different client for CLI
* disable Dex by default
* move Terraform module at repository root
* use var.cluster_info

### Features

* Add a variable to choose a branch ([39e25be](https://github.com/camptocamp/devops-stack-module-argocd/commit/39e25bec835c196498fbcae53cc0403f4574484f))
* add bootstrap submodule ([98332d3](https://github.com/camptocamp/devops-stack-module-argocd/commit/98332d3e6518abaaf5371615f5f79e7d6469eaaf))
* add eks ([2c73f76](https://github.com/camptocamp/devops-stack-module-argocd/commit/2c73f76f8eeb637d4f2214c0821921c368dde268))
* always set argoCD to insecure for provider ([c9a7def](https://github.com/camptocamp/devops-stack-module-argocd/commit/c9a7deff549801524588e1fef617c25e31487426))
* disable Dex by default ([8ae2272](https://github.com/camptocamp/devops-stack-module-argocd/commit/8ae2272ef8b595e1cf05cdcd80419efe08630dd1))
* disable Dex by default ([318dd17](https://github.com/camptocamp/devops-stack-module-argocd/commit/318dd177db87bae1fd48a2c8f989df3fcf84874c))
* **oidc:** pass argocd specific oidc configuration as variable ([afe1b10](https://github.com/camptocamp/devops-stack-module-argocd/commit/afe1b104face51cbf9ff28cbb5aca6656c820c83))
* remove k3s and eks submodules, add admin_enabled variable ([55094b4](https://github.com/camptocamp/devops-stack-module-argocd/commit/55094b4f136e84117ab14b0f52316399285f9a00))


### Bug Fixes

* add default value for oidc ([459d4a1](https://github.com/camptocamp/devops-stack-module-argocd/commit/459d4a131191e724a98d29ba6222f06aec192817))
* **argocd_application:** set wait=true ([989463b](https://github.com/camptocamp/devops-stack-module-argocd/commit/989463b7887aacea6f27ac825a4ea177a9adc5e3))
* **bootstrap:** correct Helm chart path ([23a23d6](https://github.com/camptocamp/devops-stack-module-argocd/commit/23a23d6e4b6e434400207e4ad22387c075ff51af))
* **chart:** do not hardcode dependencies versions in Chart.yaml ([6aa7e5a](https://github.com/camptocamp/devops-stack-module-argocd/commit/6aa7e5aebeb246ba26164680cbf4a4a88254d6bb))
* configure OIDC after bootstrap ([a18b7ad](https://github.com/camptocamp/devops-stack-module-argocd/commit/a18b7ad405442f95541b157600911c001ecdb0a3))
* configure OIDC after bootstrap ([de69047](https://github.com/camptocamp/devops-stack-module-argocd/commit/de6904795e1f0d10fdce4ab5e3d74902f361c5b5))
* do not delay Helm values evaluation ([ae809cc](https://github.com/camptocamp/devops-stack-module-argocd/commit/ae809cc8bdae2d7643a1868c7a98952c9df316ff))
* do not delay Helm values evaluation ([3026256](https://github.com/camptocamp/devops-stack-module-argocd/commit/3026256270692bbcd28960a76ecb4e96541e9c6d))
* improve convergence ([190e04d](https://github.com/camptocamp/devops-stack-module-argocd/commit/190e04d25047e23f4980748d8ceae72f9c900f38))
* merge conflict ([45e5b54](https://github.com/camptocamp/devops-stack-module-argocd/commit/45e5b541eb19fe1febe4d0e1000f55dc45da15a4))
* **oidc:** do not alter default requested scopes ([dbf86f5](https://github.com/camptocamp/devops-stack-module-argocd/commit/dbf86f583059c78c196570f1e6003d3d27954b52))
* **oidc:** use a different client for CLI ([ded6a3a](https://github.com/camptocamp/devops-stack-module-argocd/commit/ded6a3a1c8d244a287fbfd9aed28a3406632de6c))
* pass server_admin_password as htpassword bcrypt ([976e51e](https://github.com/camptocamp/devops-stack-module-argocd/commit/976e51e1d9cd9702a8fcf7062f561ed1248d7f05))
* README ([c5415dc](https://github.com/camptocamp/devops-stack-module-argocd/commit/c5415dc0149b649d1d89c5da931cfa2508dbc36d))
* separate variables for bootstrap module ([0cddc54](https://github.com/camptocamp/devops-stack-module-argocd/commit/0cddc54fae964cc85e023063087f4bf2f7e0b72a))


### Code Refactoring

* move Terraform module at repository root ([bcde2e5](https://github.com/camptocamp/devops-stack-module-argocd/commit/bcde2e560f0b981171b93f4544c41c1f2b767dd5))
* use var.cluster_info ([7f01eca](https://github.com/camptocamp/devops-stack-module-argocd/commit/7f01ecaafaaba49f5c9edd1d94d22cef2231a520))


### Continuous Integration

* add central workflows including release-please ([#15](https://github.com/camptocamp/devops-stack-module-argocd/issues/15)) ([92da6a5](https://github.com/camptocamp/devops-stack-module-argocd/commit/92da6a55d7324ef2887fba9143e61da17e50784e))
