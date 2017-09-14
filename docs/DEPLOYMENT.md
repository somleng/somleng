# Deployment

## AWS Elastic Beanstalk

### Set up a VPC

See [Setup AWS VPC with public and private subnets](https://github.com/somleng/twilreapi/blob/master/docs/AWS_VPC_SETUP.md)

### Create a Bastion Host (optional)

Since the EC2 Instances are launched in the private subnets, you cannot access them from the Internet. Follow [this guide](https://github.com/somleng/twilreapi/blob/master/docs/AWS_BASTION_HOST.md) to setup a Bastion Host in order to connect to your instances on the private subnet.

Note although not officially recommended, if you're also [setting up FreeSWITCH](https://github.com/somleng/freeswitch-config) on a public subnet you could also use this instance as the Bastion Host.

### Create a new web application environment

Launch a new web application environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted if you want to associate a public IP Address select No. When prompted for EC2 subnets, enter your *private* subnets. When prompted for your ELB subnets enter your *public* subnets. This will set up your environment similar to what is shown in [this diagram](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html).

```
$ eb platform select --profile <profile-name>
$ eb create --vpc -r <region> --profile <profile-name>
```

Set the following ENV Variables:

```
SECRET_KEY_BASE=`bundle exec rails secret`
RAILS_MAX_THREADS=32
```

Note `RAILS_MAX_THREADS=32` comes from the default configuration for puma on Elastic Beanstalk. The setting is in `/opt/elasticbeanstalk/support/conf/pumaconf.rb`

#### Connecting to RDS

Follow [this guide](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/AWSHowTo.RDS.html?icmpid=docs_elasticbeanstalk_console)

This needs to be done on both the web and worker environments.

#### Setting up the Database

##### Set the DATABASE_URL

```
$ eb setenv -e <environment-name> --profile <profile-name> DATABASE_URL=postgres://database-endpoint
```

##### SSH into instance through Bastion Host

```
$ eb ssh <environment-name> --profile <profile-name> -e "ssh -A"
```

##### SSH into Twilreapi instance

```
$ ssh <ip-of-twilreapi-instance>
```

CREATE_ADMIN_ACCOUNT=1 ADMIN_ACCOUNT_PERMISSIONS=comma_separated_list_of_permissions bin/rails db:seed

##### Move into source code directory and su to root

```
$ cd /var/app/current
$ sudo su
```

##### Load the database schema

```
$ bundle exec rake db:schema:load
```

##### Setup an admin account for managing Inbound Phone Calls

```
$ CREATE_ADMIN_ACCOUNT=1 ADMIN_ACCOUNT_PERMISSIONS=manage_inbound_phone_calls bundle exec rake db:seed
```

##### Setup an admin account for managing Phone Call Events

```
$ CREATE_ADMIN_ACCOUNT=1 ADMIN_ACCOUNT_PERMISSIONS=manage_phone_call_events bundle exec rake db:seed
```

##### Setup an admin account for managing Call Data Records

```
$ CREATE_ADMIN_ACCOUNT=1 ADMIN_ACCOUNT_PERMISSIONS=manage_call_data_records bundle exec rake db:seed
```

##### Setup an admin account for managing AWS SNS Messages

```
$ CREATE_ADMIN_ACCOUNT=1 ADMIN_ACCOUNT_PERMISSIONS=manage_aws_sns_messages bundle exec rake db:seed
```

##### Setup a user account

```
$ bundle exec rake db:seed
```

#### Setup Background Processing

In order to queue jobs to SQS, support for [active_elastic_job](https://github.com/tawan/active-elastic-job) is built in. Follow the [README](https://github.com/tawan/active-elastic-job).

To use [Active Elastic Job](https://github.com/tawan/active-elastic-job) set the following ENV Variables in your web environment: `ACTIVE_JOB_USE_ACTIVE_JOB=1 ACTIVE_JOB_QUEUE_ADAPTER=active_elastic_job AWS_REGION=<your-aws-region>`

##### Processing Outbound Calls

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_OUTBOUND_CALL_WORKER_QUEUE` in your web environment. The queue name will be generated when you create the worker environment (see below).

##### Processing CDRs

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_CALL_DATA_RECORD_WORKER_QUEUE` in your web environment. The queue name will be generated when you create the worker environment (see below).

Create an IAM user which has access to S3 and a bucket in which to store the CDRs. Then set the following ENV variables in your web environment:

```
CDR_STORAGE=s3
AWS_S3_REFILE_BUCKET=bucket-to-store-cdrs
AWS_REGION=region
AWS_S3_REFILE_STORE_PREFIX=store
AWS_ACCESS_KEY_ID=access-key-id-of-user-who-as-access-to-bucket
AWS_SECRET_ACCESS_KEY=secret-access-key-id-of-user-who-as-access-to-bucket
```

##### Sending Status Callback Notifications

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_STATUS_CALLBACK_NOTIFIER_WORKER_QUEUE` in your web *and* worker environments. The queue name will be generated when you create the worker environment (see below). Note that you need to set this environment variable in both your web and CDR processor worker environment since the job will be when a phone call is completed which could be due to a phone call event or a CDR.

##### Processing Recordings

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_RECORDING_PROCESSOR_WORKER_QUEUE` in your web environment. The queue name will be generated when you create the worker environment (see below).

##### Processing AWS SES Messages

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_AWS_SNS_MESSAGE_PROCESSOR_WORKER_QUEUE` in your web environment. The queue name will be generated when you create the worker environment (see below).

##### Sending Recording Status Callback Notifications

RecordingStatusCallbackNotifierJob recording_status_callback_notifier_worker

Set the SQS queue name in the ENV variable `ACTIVE_JOB_ACTIVE_ELASTIC_JOB_RECORDING_STATUS_CALLBACK_NOTIFIER_WORKER_QUEUE` in your *Process Recordings worker environment*. The queue name will be generated when you create the worker environment (see below).

### Create worker environments

Create a worker environment for Processing Outbound Calls (twilreapi-outbound-call-processor) and another for Processing CDRs (twilreapi-cdr-processor).

Launch a new worker environment using the ruby (Puma) platform. When prompted for the VPC, enter the VPC you created above. When prompted for EC2 subnets, enter the *private* subnets (separated by a comma for both availability zones). Enter the same for your ELB subnets (note there is no ELB for Worker environments so this setting will be ignored)

```
$ eb create --vpc --tier worker -i t2.nano --profile <profile-name>
```

#### Setup worker environments

Ensure you set `DATABASE_URL` and `SECRET_KEY_BASE` to the same values as you specified for the web environment. In addition specify the following variables:

```
RAILS_SKIP_ASSET_COMPILATION=true
RAILS_SKIP_MIGRATIONS=true
PROCESS_ACTIVE_ELASTIC_JOBS=true
RAILS_MAX_THREADS=32
```

For the worker environment that processes outbound calls set the following variables:

```
TWILREAPI_WORKER_JOB_OUTBOUND_CALL_JOB_DRB_URL=druby://somleng-host-url:9050
```

For the worker environment that processes CDRs set the S3 storage configuration variables to the [same values](#processing-cdrs) as you set in the web environment

For the worker environment that sends Recording Status Callback Notifications set either (or both) of the following environment variables:

```
RECORDING_URL_HOST=cdn.hostname.org
APPLICATION_HOST=somleng.hostname.org
```

`RECORDING_URL_HOST` takes precedence over `APPLICATION_HOST`. `RECORDING_URL_HOST` is used to determine the full URL of the recording when sent as a Recording Status Callback Notification. This is useful if you're using a CDN to deliver recordings. If `RECORDING_URL_HOST` is not set `APPLICATION_HOST` is used instead. If neither are set the relative path to the recording is returned instead.

#### Configure the SQS queue

If you use the autogenerated queue for your worker environment then a dead-letter queue is automatically configured. This setting can be configured in the Elastic Beanstalk web console.

#### Setup Autoscaling based on SQS queue size

I followed [this article](http://blog.cbeer.info/2016/autoscaling-elasticbeanstalk-workers-sqs-length/) but not the section on CloudFormation. The important steps are:

1. Create two CloudWatch alarms for each SQS queue using the AWS CloudWatch console using the metric `ApproximateNumberOfMessagesVisible`. One alarm should be for scaling up, and the other for scaling down.
2. Attach the alarm to the AutoScaling group which was created by Elastic Beanstalk for the worker environment.

### CI Deployment

See [CI DEPLOYMENT](https://github.com/somleng/twilreapi/blob/master/docs/CI_DEPLOYMENT.md)

### SSH to the worker environment

Since the worker environment is on a private subnet, you can't reach it from the Internet. Instead ssh into your web environment and use ssh forwarding get to your worker instance.

```
$ eb ssh -e "ssh -A"
$ [ec2-user@private_ip_of_web_env ~]$ ssh <private_ip_of_worker_env>
```

### Running rake tasks on the server

```
$ cd /var/app/current
$ sudo su
$ bundle exec rake <task>
```
