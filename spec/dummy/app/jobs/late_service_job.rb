# frozen_string_literal: true

module Aws
  module LateService
    autoload :Client,
             File.expand_path('../../lib/aws/late_service/client', __dir__)
  end
end

class LateServiceJob < ApplicationJob; end
