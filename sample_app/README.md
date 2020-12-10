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

TODO

## DynamoDB Session Store

TODO

## ActiveSupport Notifications

TODO

## SQS ActiveJob

TODO

## AWS Record Generators

TODO
