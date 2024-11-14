# frozen_string_literal: true

module Aws
  # Use the Rails namespace.
  module Rails
    # @api private
    class Railtie < ::Rails::Railtie
      initializer 'aws-sdk-rails.initialize',
                  before: :load_config_initializers do
        # Initialization Actions
        Aws::Rails.log_to_rails_logger
        Aws::Rails.use_rails_encrypted_credentials
        Aws::Rails.add_action_mailer_delivery_method
        Aws::Rails.add_action_mailer_delivery_method(:sesv2)

        if %i[ses sesv2].include?(::Rails.application.config.action_mailer.delivery_method)
          ::Rails.logger.warn(<<~MSG)
            ** Aws::Rails.add_action_mailer_delivery_method will be removed in aws-sdk-rails ~> 5.
            If you are using this feature, please add your desired delivery methods in an initializer
            (such as config/initializers/action_mailer.rb):

                options = { ... SES client options ... }
                ActionMailer::Base.add_delivery_method :ses, Aws::ActionMailer::SESMailer, **options
                ActionMailer::Base.add_delivery_method :ses_v2, Aws::ActionMailer::SESV2Mailer, **options

            Existing Mailer classes have moved namespaces but will continue to work in this major version. **
          MSG
        end
      end

      initializer 'aws-sdk-rails.insert_middleware' do |app|
        Aws::Rails.add_sqsd_middleware(app)
      end

      initializer 'aws-sdk-rails.eager_load' do
        Aws.define_singleton_method(:eager_load!) do
          Aws.constants.each do |c|
            m = Aws.const_get(c)
            next unless m.is_a?(Module)

            m.constants.each do |constant|
              m.const_get(constant)
            end
          end
        end

        config.before_eager_load do
          config.eager_load_namespaces << Aws
        end
      end

      rake_tasks do
        load 'tasks/dynamo_db/session_store.rake' if defined?(Aws::ActionDispatch::DynamoDb)
        load 'tasks/aws_record/migrate.rake' if defined?(Aws::Record)
      end
    end

    # Configures the AWS SDK for Ruby's logger to use the Rails logger.
    def self.log_to_rails_logger
      Aws.config[:logger] = ::Rails.logger
      nil
    end

    # Configures the AWS SDK with credentials from Rails encrypted credentials.
    def self.use_rails_encrypted_credentials
      # limit the config keys we merge to credentials only
      aws_credential_keys = %i[access_key_id secret_access_key session_token account_id]
      creds = ::Rails.application.credentials[:aws].to_h.slice(*aws_credential_keys)
      Aws.config.merge!(creds)
    end

    # This is called automatically from the SDK's Railtie, but can be manually
    # called if you want to specify options for building the Aws::SES::Client or
    # Aws::SESV2::Client.
    #
    # @param [Symbol] name The name of the ActionMailer delivery method to
    #   register, either :ses or :sesv2.
    # @param [Hash] client_options The options you wish to pass on to the
    #   Aws::SES[V2]::Client initialization method.
    def self.add_action_mailer_delivery_method(name = :ses, client_options = {})
      # TODO: remove this method in aws-sdk-rails ~> 5
      ActiveSupport.on_load(:action_mailer) do
        if name == :sesv2
          add_delivery_method(name, Aws::Rails::Sesv2Mailer, client_options)
        else
          add_delivery_method(name, Aws::Rails::SesMailer, client_options)
        end
      end
    end

    # Add ActiveSupport Notifications instrumentation to AWS SDK client operations.
    # Each operation will produce an event with a name `<operation>.<service>.aws`.
    # For example, S3's put_object has an event name of: put_object.S3.aws
    def self.instrument_sdk_operations
      Aws.constants.each do |c|
        m = Aws.const_get(c)
        if m.is_a?(Module) && m.const_defined?(:Client) &&
           (client = m.const_get(:Client)) && client.superclass == Seahorse::Client::Base
          m.const_get(:Client).add_plugin(Aws::Rails::Notifications)
        end
      end
    end

    # Register a middleware that will handle requests from the Elastic Beanstalk worker SQS Daemon.
    # This will only be added in the presence of the AWS_PROCESS_BEANSTALK_WORKER_REQUESTS environment variable.
    # The expectation is this variable should only be set on EB worker environments.
    def self.add_sqsd_middleware(app)
      return unless ENV['AWS_PROCESS_BEANSTALK_WORKER_REQUESTS']

      if app.config.force_ssl
        # SQS Daemon sends requests over HTTP - allow and process them before enforcing SSL.
        app.config.middleware.insert_before(ActionDispatch::SSL, Aws::ActiveJob::SQS::EBMiddleware)
      else
        app.config.middleware.use(Aws::ActiveJob::SQS::EBMiddleware)
      end
    end
  end
end
