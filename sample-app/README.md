# aws-sdk-rails Sample App

This is a minimal app created with `rails new --minimal --skip-git sample-app`

An additional user scaffold was created with: `bundle exec rails generate scaffold user email:uniq password:digest`. Gem `bcrypt` was added to the Gemfile.

The database was migrated with: `bundle exec rails db:migrate`.

Our gems (`aws-sdk-rails` + feature gems) were added to the Gemfile.

Gem `byebug` is added to help with development.

## AWS Rails Logger

### Setup

The Railtie is already configured to setup the Rails logger as the global `Aws.config[:logger]`.

### Testing

Run `bundle exec rails console` to start the console.

Inspect the output of `Aws.config[:logger]` and ensure it is an `ActiveSupport` logger.

## Encrypted Credentials

### Setup

Run `EDITOR=nano bundle exec rails credentials:edit` to edit credentials.

Commented credentials are defined under the `:aws` key. Uncomment the credentials, which should look like:

```yaml
aws:
  access_key_id: secret
  secret_access_key: akid
  session_token: token
  account_id: account
```

### Testing

Run `bundle exec rails console` to start the console.

Inspect the output of `Aws.config` and ensure the credentials are set.

## ActiveSupport Notifications

### Setup

This is configured in `config/initializers/instrument_aws_sdk.rb`. See the `aws-sdk-rails` README.

`UsersController#index` captures any AWS SDK notification with:

```ruby
ActiveSupport::Notifications.subscribe(/[.]aws/) do |name, start, finish, id, _payload|
  Rails.logger.info "Got notification: #{name} #{start} #{finish} #{id}"
end
```

### Testing

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/users`.

In the logs, you should at least see a notification for DynamoDB `update_item` from the session store.
It should look like:

```
Got notification: update_item.DynamoDB.aws ...
```

## ActionDispatch DynamoDB Session

### Setup

This is configured in `config/initializers/session_store.rb`. See [this guide](https://guides.rubyonrails.org/configuring.html#config-session-store) and the `aws-sdk-rails` README.

The default configuration file was generated with `bundle exec rails generate dynamo_db:session_store_config`.

The ActiveRecord session table migration was created with `bundle exec rails generate dynamo_db:session_store_migration`.

To create the table if it doesn't already exist, run `bundle exec rake dynamo_db:session_store:create_table`.

To override changes, change this app's Gemfile to use the local path.

### Testing

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/users`.

In the logs, you should see a notification for DynamoDB `update_item` with a `session_id`. This key should exist in your DynamoDB `sessions` table. Refreshing the page should update the session `updated_at` and/or `expired_at` and not create a new session.

## ActionMailer mailers

### Setup

The mailer was generated with `bundle exec rails generate mailer Test`.

An empty controller scaffold was generated with `bundle exec rails generate controller Mailer`.

`ApplicationMailer` was set to use `ENV['ACTION_MAILER_EMAIL']`.

`TestMailer` implemented SES and SESv2 mailer methods.

`MailerController` (and routes) were added to send mail.

`config/application.rb` added `require "action_mailer/railtie"`.

Delivery methods are configured in `config/initializers/action_mailer.rb`.

### Testing

Start the service with `ACTION_MAILER_EMAIL=<your email> bundle exec rails server`.

> **Important**: The email address in SES must be verified.

Visit `http://127.0.0.1:3000/send_ses_email` or `http://127.0.0.1:3000/send_ses_v2_email` and check your email.

## ActionMailbox ingress

### Setup

Following [this guide](https://guides.rubyonrails.org/action_mailbox_basics.html), ActionMailbox was setup with `bundle exec bin/rails action_mailbox:install`.

The database was migrated with: `bundle exec rails db:migrate`.

The ingress and ActiveStorage was configured in `config/environments/development.rb` with:

```ruby
config.active_storage.service = :local
config.action_mailbox.ingress = :ses
```

A default route was added to `app/mailboxes/application_mailbox.rb`.

The test mailbox was created with `bundle exec rails generate mailbox test`.

### Testing

This feature can't fully be tested end to end unless the rails application is hosted on a domain. The SNS topic would have to notify a route such as `https://example.com/rails/action_mailbox/ses/inbound_emails`.

Future work could deploy this sample-app behind a domain to fully test it.

Start the service with `bundle exec rails server` and visit `http://127.0.0.1:3000/rails/conductor/action_mailbox/inbound_emails`.

Click "New inbound email by source".

Use the following message (other messages can be created and signed in aws-actionmailbox-ses):

```
Return-Path: <bob@example.com>
Received: from example.com (example.com [127.0.0.1])
 by inbound-smtp.us-east-1.amazonaws.com with SMTP id 17at0jiq08p0449huhf16qsmdi6sa1ltm069t801
 for test@test.example.com;
 Wed, 02 Sep 2020 01:30:50 +0000 (UTC)
X-SES-Spam-Verdict: PASS
X-SES-Virus-Verdict: PASS
X-SES-RECEIPT: AEFBQUFBQUFBQUFHMWlxem9Gb1ZOemNkamlTeFlYdlZUSmUwVVZhYndjK213dHFIM0dVRTYwUlk1UlpBQVVVTXhQRUd1MTN6YTFJalp0TFdMZjhOOUZGSlJCYkxEV2craXhpOG02d2xDc2FtY2dNdVMvRE9QWWpNVkxBWVZzMyt5MHBTUXV5KzM5aDY1Vng5UnZsZTdTK2dGVDF5RVc1QndOd0xvbndNRlR3TDZjd2cxT2c2UVFQbVN2andMS09VM2R5elFrTGk3RnF0WXI3WDZ1alhkUzJxdzhzU1dwT3FPZEFsU0VNc3RpTWM0QStFZDB5RFd5SnpRelBJWnJjelZPRytudEVpNTc5dVZRUXMra2lrby9wOExhR3JqTi9xNkZnNHREN3BmSmVYS25Jeis2NDRyaEE9PQ==
X-SES-DKIM-SIGNATURE: a=rsa-sha256; q=dns/txt; b=WGBoUguIq9047YXpCaubVCtm/ISR3JEVkvm/yAfL2MrAryQcYsTdUM6zzStPyvOm0QsonOKsWJ0O2YyuQDX1dvBmggdeUqZq08laD+Xuy1L6ODm0O/EQE9wDitj0KqXxOgMr3oM7tpcTTGLcCgXERFZbmI+1ACeeA7fbylMasIM=; c=relaxed/simple; s=224i4yxa5dv7c2xz3womw6peuasteono; d=amazonses.com; t=1599010250; v=1; bh=FUugtX/z1FFtLvVfaVhPhqhi4Gvo1Aam67iRPZYKfTo=; h=From:To:Cc:Bcc:Subject:Date:Message-ID:MIME-Version:Content-Type:X-SES-RECEIPT;
From: "Smith, Bob E" <bob@example.com>
To: "test@test.example.com"
	<test@test.example.com>
Subject: Test 500
Thread-Topic: Test 500
Thread-Index: AQHWgMisvDz2gn/lKEK/giPayBxk7g==
Date: Wed, 2 Sep 2020 01:30:43 +0000
Message-ID: <1344C740-07D3-476E-BEE7-6EB162294DF6@example.com>
Accept-Language: en-US
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CEC7772B8DEC7E4FAC59C3E8219E7AFB@namprd04.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0

Aaaron
```

You should see the message say delivered and not bounced.

## ActiveJob SQS

### Setup

The jobs were generated with `bundle exec rails generate job Test` and `bundle exec rails generate job TestAsync`.

An empty controller scaffold was generated with `bundle exec rails generate controller Job`.

`TestJob` and `TestAsyncJob` was implemented to print the job's args.

`JobController` and routes were added to queue the job.

`config/application.rb` added `require "active_job/railtie"`.

> **Important**: Create an SQS queue and retrieve the queue URL.

### Testing

Start rails with `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec rails server`

Poll for and process jobs with: `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec aws_sqs_active_job --queue default`

Visit `http://127.0.0.1:3000/queue_sqs_job` and `http://127.0.0.1:3000/queue_sqs_async_job` to queue jobs. The output of both jobs should be printed in the logs.

### Testing with ElasticBeanstalk workers

Create a EB application with a worker environment (rather than web server environment) using the Ruby platform. Use the default settings (including using the default/sample app initially) except:
1. (Optional) Set an EC2 key pair.
2. Choose the default VPC and enable all of the subnets. Enable a public IP address.
3. Set the root volume to General Purpose 3.
4. Select a bigger instance than the micro default, such as m7.large.
5. Set the worker queue to your personal queue. You can create a new queue such as `sample-app-worker` in the SQS console.
6. Set `AWS_PROCESS_BEANSTALK_WORKER_REQUESTS` to `true` in the environment configuration.

After initial deployment of the sample app, create a zip of the sample-app: `zip ../sample-app.zip -r * .[^.]*`.  Create a new version and deploy it.

Run the sample-app locally and submit jobs:
1. `rails c`
2. `TestJob.perform_later(hello: 'from ebs')` 

You can then request the logs and should see processing of the job in `/var/log/puma/puma.log`

### Testing with Docker ElasticBeanstalk workers

* Install the [eb cli](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html#eb-cli3-install.scripts).  
* Ensure docker is running.
* Create a docker application using `eb create` and then create a worker environment using `eb create -t worker -it t3.large`. Note: this will create a new SQS queue.
* Update local sqs active job config to use the new queue and submit a test job: `rails c` and then `TestJob.perform_later(hello: 'from ebs')`

> **Note**: The dockerfile must set `AWS_PROCESS_BEANSTALK_WORKER_REQUESTS="true"` and `SECRET_KEY_BASE="fortestonly"`.

## Deploying / Testing on ElasticBeanstalk Web Server

Create a EB application with a web server environment using the Ruby platform. Use the default settings (including using the default/sample app initially) except:
1. (Optional) Set an EC2 key pair.
2. Choose the default VPC and enable all of the subnets. Enable a public IP address.
3. Set the root volume to General Purpose 3.
4. Select a bigger instance than the micro default, such as m7.large.
5. Set `SECRET_KEY_BASE` to `SECRET` in the environment configuration.

In `config/environments/production.rb` the following configuration has been changed:

```ruby
  config.assume_ssl = false
  config.force_ssl = false
  config.ssl_options = { redirect: false, secure_cookies: false, hsts: false }
```

The following config was added to `sample-app/.platform/nginx/conf.d/10-types-hash.conf`:

```
types_hash_max_size 4096;
```

After initial deployment of the sample app, create a zip of the sample-app: `zip ../sample-app.zip -r * .[^.]*`. Create a new version and deploy it.

You can find web logs under `/var/log/puma/puma.log`