Unreleased Changes
------------------
* Issue - Merge only credential related keys from Rails encrypted credentials
into `Aws.config`.

3.0.5 (2019-10-17)
------------------

* Upgrading - Adds support for Rails Encrypted Credentials, requiring Rails 5.2+
and thus needed a new major version. Consequently drops support for Ruby < 2.3
and for Rails < 5.2. Delivery method configuration changed from `:aws_sdk` to
`:ses`, to allow for future delivery methods. Adds rubocop to the package and
fixed many violations. This test framework now includes a dummy application for
testing future features.

2.1.0 (2019-02-14)
------------------

* Feature - Aws::Rails::Mailer - Adds the Amazon SES message ID as a header to
raw emails after sending, for tracking purposes. See
[related GitHub pull request #25](https://github.com/aws/aws-sdk-rails/pull/25).

2.0.1 (2017-10-03)
------------------

* Issue - Ensure `aws-sdk-rails.initialize` executes before
`load_config_initializers`

2.0.0 (2017-08-29)
------------------

* Upgrading - Support version 3 of the AWS SDK for Ruby. This is being released
as major version 2 of `aws-sdk-rails`, though the APIs remain the same. Do note,
however, that we've changed our SDK dependency to only depend on `aws-sdk-ses`.
This means that if you were depending on other service clients transitively via
`aws-sdk-rails`, you will need to add dependencies on the appropriate service
gems when upgrading. Logger integration will work for other service gems you
depend on, since it is wired up against `aws-sdk-core` which is included in
the `aws-sdk-ses` dependency.

1.0.1 (2016-02-01)
------------------

* Feature - Gemfile - Replaced `rails` gem dependency with `railties`
  dependency. With this change, applications that bring their own dependencies
  in place of, for example, ActiveRecord, can do so with reduced bloat.

  See [related GitHub pull request
  #4](https://github.com/aws/aws-sdk-rails/pull/4).

1.0.0 (2015-03-17)
------------------

* Initial Release: Support for Amazon Simple Email Service and Rails Logger
  integration.
