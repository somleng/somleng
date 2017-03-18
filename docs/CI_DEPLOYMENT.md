# CI Deployment

Automating deployment through CI has multiple advantages and is highly recommended. Once set up you don't need to worry about deploying to multiple environments or accidently deploying the wrong branch to the wrong application.

## Travis

To setup deployment via [Travis](https://travis-ci.org/) to Elastic Beanstalk do the following:

1. Add a new user for travis using the AWS IAM dashboard
2. Add the user to a new group called `ci`
3. Add the following Managed Policies to the `ci` group:

    * AmazonS3FullAccess
    * AWSElasticBeanstalkFullAccess

4. Add a new bucket for travis to put the application versions. Put it in the correct region for your application.
5. Configure `.travis.yml` to deploy to AWS Elastic Beanstalk for each environment. Making sure to encrypt your AWS credentials. See [this example](https://github.com/dwilkie/twilreapi/blob/app.somleng.org/.travis.yml). To encrypt your AWS credentials use the the travis cli and copy and paste the values into `.travis.yml`:

    * `$ travis encrypt <AWS_ACCESS_KEY_ID>`
    * `$ travis encrypt <AWS_SECRET_ACCESS_KEY>`

Once you're all setup you can deploy with:

```
$ git push origin <branch-name>
```

## Deploying to Elastic Beanstalk (Multi-Container Docker) applications

When deploying Docker to Elastic Beanstalk you should wait for the build to finish on [Dockerhub](https://hub.docker.com) before triggering the CI deployment, because Elastic Beanstalk will pull the latest build from Dockerhub when deploying.

To set this up you can use [dockerhub2ci](https://github.com/dwilkie/dockerhub2ci). See the [README](https://github.com/dwilkie/dockerhub2ci) for installation instructions.
