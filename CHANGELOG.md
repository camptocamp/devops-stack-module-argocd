# Changelog

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
