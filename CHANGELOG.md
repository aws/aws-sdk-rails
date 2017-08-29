Unreleased Changes
------------------

* Upgrading - Support version 3 of the AWS SDK for Ruby. This is being released as major version 2 of `aws-sdk-rails`, though the APIs remain the same. Do note, however, that we've changed our SDK dependency to only depend on `aws-sdk-ses`. This means that if you were depending on other service clients transitively via `aws-sdk-rails`, you will need to add dependencies on the appropriate service gems when upgrading. Logger integration will work for other service gems you depend on, since it is wired up against `aws-sdk-core` which is included in the `aws-sdk-ses` dependency.

1.0.1 (2016-02-01)
------------------

* Feature - Gemfile - Replaced `rails` gem dependency with `railties`
  dependency. With this change, applications that bring their own dependencies
  in place of, for example, ActiveRecord, can do so with reduced bloat.

  See [related GitHub pull request #4](https://github.com/aws/aws-sdk-rails/pull/4).

1.0.0 (2015-03-17)
------------------

* Initial Release: Support for Amazon Simple Email Service and Rails Logger
  integration.
