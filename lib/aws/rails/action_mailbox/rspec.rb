# frozen_string_literal: true

# This can be deleted in aws-sdk-rails ~> 5

require 'aws/action_mailbox/ses/rspec'
Aws::Rails::ActionMailbox::RSpec = Aws::ActionMailbox::SES::RSpec

Kernel.warn('Aws::Rails::ActionMailbox::RSpec is deprecated in aws-sdk-rails ~> 5. ' \
            'Use Aws::ActionMailbox::SES::RSpec instead.')
Kernel.warn('Please require "aws/action_mailbox/ses/rspec" instead of "aws/rails/action_mailbox/rspec"')
