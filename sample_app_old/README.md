# README

Sample app using `aws-sdk-rails` features. Used for development and testing.

* Ruby version

3.3.0

* Database creation

`rails db:migrate`

## SES (Inbound)

Fixture based testing of SES is possible via RSpec request helpers that this gem offers. How to use them is documented within the main README. How to setup inbound emails with SES is also covered there.

## SQS ActiveJob

* Start rails with `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url rails server`
* Visit/curl `http://127.0.0.1:3000/test-job?name=my_name` - This will queue a job up
* Poll for and process jobs with: `AWS_ACTIVE_JOB_QUEUE_URL=https://my_sqs_queue_url bundle exec aws_sqs_active_job --queue default`
