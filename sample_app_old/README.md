# README

Sample app using `aws-sdk-rails` features. Used for development and testing.

* Ruby version

3.3.0

* Database creation

`rails db:migrate`

## ActiveStorage

Start rails with `ACTIVE_STORAGE_BUCKET=my_bucket rails server`

Upload an `:avatar` using the `/users` route.

## SES (Outbound)

Start rails with `ACTION_MAILER_EMAIL=my@email.com rails server`

Send an email using the `/emails/index` route.

Make sure your email address is verified in SES.

## SES (Inbound)

Fixture based testing of SES is possible via RSpec request helpers that this gem offers. How to use them is documented within the main README. How to setup inbound emails with SES is also covered there.

## AWS Record Generators

Run `rails g aws_record:model Forum --table-config primary:10-5`

To migrate run `rails aws_record:migrate`
