require 'aws-record'

class TestScaffoldHelpers
  include Aws::Record
  extend ActiveModel::Naming

  string_attr :uuid, hash_key: true
  
  # Scaffolding helpers
  def initialize(args = {})
    super
    @errors = ActiveModel::Errors.new(self)
  end

  attr_reader :errors

  def to_model
    self
  end

  def to_param
    return nil unless persisted?

    hkey = public_send(self.class.hash_key)
    if self.class.range_key
        rkey = public_send(self.class.range_key)
        "#{CGI.escape(hkey)}&#{CGI.escape(rkey)}"
    else
        "#{CGI.escape(hkey)}"
    end
  end
end
