# README

Sample app using `aws-sdk-rails` features. Used for development and testing.

* Ruby version

2.6.6

* Database creation

`rails db:migrate`

## ActiveStorage

Start rails with `ACTIVE_STORAGE_BUCKET=my_bucket rails server`

Upload an `:avatar` using the `/users` route.

## Rails Encrypted Credentials

Add credentials under `:aws` key after running:

`EDITOR=nano rails credentials:edit`

## SES

Start rails with `ACTION_MAILER_EMAIL=my@email.com rails server`

Send an email using the `/emails/index` route.

Make sure your email address is verified in SES.

## DynamoDB Session Store

This should already be configured following the README.

Running `rails db:migrate` will create the session table in DynamoDB.

To override changes, change this app's Gemfile to use the local dependency.

## ActiveSupport Notifications

ActiveSupport notifications for AWS clients are configured in
`config/initializers/instrument_aws_sdk/rb` to log an event
whenever an AWS client makes any service calls.  To demo, follow
any one of the ActiveStorage, SES or SQS ActiveJob and the
AWS calls should be logged with:
`Recieved an ActiveSupport::Notification for: send_message.SQS.aws event`

## SQS ActiveJob

* Start rails with `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url rails server`
* Visit/curl `http://127.0.0.1:3000/test-job?name=my_name` - This will queue a job up
* Poll for and process jobs with: `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec aws_sqs_active_job --queue default`

## AWS Record Generators

Run `rails g aws_record:model Forum --table-config primary:10-5`

To migrate run `rails aws_record:migrate`
