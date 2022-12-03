# Somleng

[![GitHub Action](https://github.com/somleng/somleng/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/somleng/actions)
[![View performance data on Skylight](https://badges.skylight.io/status/DvGhX1IYIjrx.svg)](https://oss.skylight.io/app/applications/DvGhX1IYIjrx)
[![Codacy Badge](https://app.codacy.com/project/badge/Coverage/e1f941eb9ba34197a87ddc5a930558bd)](https://www.codacy.com/gh/somleng/somleng/dashboard?utm_source=github.com&utm_medium=referral&utm_content=somleng/somleng&utm_campaign=Badge_Coverage)

Somleng (part of [The Somleng Project](https://github.com/somleng/somleng-project)) is an Open Source Cloud Communications Platform as a Service (CPaaS).

You can use Somleng to roll out your own programmable voice and SMS to:

* 🏥 [Save lives](https://www.somleng.org/case_studies.html#early-warning-system-cambodia)
* 🧒🏽 [Improve the lives of children](https://www.somleng.org/case_studies.html#mhealth-unicef-guatemala)
* 🤑 [For fun or profit](https://www.somleng.org/case_studies.html#powering-cpaas-mexico)

## Documentation

* 📚 [Documentation](https://www.somleng.org/docs.html)

## Getting Started

In order to get the full Somleng stack up and running on your development machine, please follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide.


## Deployment

The [infrastructure directory](https://github.com/somleng/somleng/tree/develop/infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng to AWS.

:warning: Our infrastructure is rapidly changing as we continue to improve and experiment with new features. We often make breaking changes to the infrastructure which usually requires some manual migration. We don't recommend that you try to deploy and run your own Somleng stack for production purposes at this stage.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
