# frozen_string_literal: true

require_relative '../../spec_helper'

module ActionDispatch
  module Session
    describe DynamodbStore do
      it 'does something' do
        store = DynamodbStore.new()
        require 'byebug'
        byebug
      end
    end
  end
end
