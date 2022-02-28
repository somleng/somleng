# Somleng

[![GitHub Action](https://github.com/somleng/somleng/actions/workflows/build.yml/badge.svg)](https://github.com/somleng/somleng/actions)
[![View performance data on Skylight](https://badges.skylight.io/status/DvGhX1IYIjrx.svg)](https://oss.skylight.io/app/applications/DvGhX1IYIjrx)

Somleng is an Open Source Cloud Communications Platform as a Service (CPaaS). It includes an open source implementation of [Twilio's REST API](https://www.twilio.com/docs/api/rest), as well as a dashboard and API for carriers to offer programmable Voice and SMS to their customers.

This repository contains the API and Dashboard. Somleng is dependent on [SomlengSWITCH](https://github.com/somleng/somleng-switch) in order to programatically orginate and terminate phone calls.

## Usage

In order to get the full Somleng stack up and running on your development machine, please follow the [GETTING STARTED](https://github.com/somleng/somleng-project/blob/master/docs/GETTING_STARTED.md) guide.

## Documentation

* [Open Source Implementation of Twilio's REST API](https://www.somleng.org/docs/twilio_api)
* [Carrier API Documentation](https://www.somleng.org/docs/carrier_api)

## Deployment

The [infrastructure directory](https://github.com/somleng/somleng/tree/develop/infrastructure) contains [Terraform](https://www.terraform.io/) configuration files in order to deploy Somleng to AWS.

:warning: The current infrastructure of Somleng is rapidly changing as we continue to improve and experiment with new features. We often make breaking changes to the current infrastructure which usually requires some manual migration. We don't recommend that you try to deploy and run your own Somleng stack for production purposes at this stage.

The infrastructure in this repository depends on some shared core infrastructure. This core infrastructure can be found in the [Somleng Project](https://github.com/somleng/somleng-project/tree/master/infrastructure) repository.

The current infrastructure deploys Somleng to AWS behind an Application Load Balancer (ALB) to Elastic Container Service (ECS). There are two main tasks, a webserver task and a worker task. The webserver task has an [NGINX container](https://github.com/somleng/somleng/blob/develop/docker/nginx/Dockerfile) which runs as a reverse proxy to the main [Rails webserver container](https://github.com/somleng/somleng/blob/develop/Dockerfile). The worker task runs as a separate ECS service.

## License

The software is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
