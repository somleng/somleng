# CI Deployment

Automating deployment through CI has multiple advantages and is highly recommended. Once set up you don't need to worry about deploying to multiple environments or accidently deploying the wrong branch.

## Travis

To setup deployment via [Travis](https://travis-ci.org/) to Elastic Beanstalk do the following:

1. Add a new user for travis using the AWS IAM dashboard
2. Add the user to a new group called `ci`
3. Add the following Managed Policies to the `ci` group:

    * AmazonS3FullAccess
    * AWSElasticBeanstalkFullAccess

4. Add a new bucket for travis to put the application versions. Put it in the correct region for your application.
5. Configure `.travis.yml` to deploy to AWS Elastic Beanstalk for each environment, making sure to encrypt your AWS credentials. See [this example](https://github.com/dwilkie/twilreapi/blob/app.somleng.org/.travis.yml).

Once you're all setup you can deploy with:

```
$ git push origin <branch-name>
```

