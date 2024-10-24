# frozen_string_literal: true

require 'test_helper'

require 'generators/aws_record/model/secondary_index'

module AwsRecord
  module Generators
    describe SecondaryIndex do
      describe 'when given correct params' do
        it 'sets its properties correctly' do
          params = 'Model:hkey{uuid},rkey{title}'

          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq('Model')
          expect(idx.hash_key).to eq('uuid')
          expect(idx.range_key).to eq('title')
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'sets its properties correctly independent of input order' do
          params = 'Model:proj_type{ALL},hkey{uuid}'

          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq('Model')
          expect(idx.hash_key).to eq('uuid')
          expect(idx.range_key).to eq(nil)
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'correctly handles underscores in field names' do
          params = 'Model:hkey{long_uuid}'

          idx = SecondaryIndex.parse(params)
          expect(idx.name).to eq('Model')
          expect(idx.hash_key).to eq('long_uuid')
        end
      end

      describe 'when given incorrect params' do
        it 'handles not being given a hash_key' do
          params = 'Model:rkey{title}'

          expect do
            SecondaryIndex.parse(params)
          end.to raise_error(ArgumentError)
        end

        it 'handles not being given any keys' do
          params = 'Model'

          expect do
            SecondaryIndex.parse(params)
          end.to raise_error(ArgumentError)
        end
      end

      describe 'when using a projection' do
        it 'correctly handles an ALL projection type' do
          params = 'Model:hkey{uuid},proj_type{ALL}'

          idx = SecondaryIndex.parse(params)
          expect(idx.projection_type).to eq('"ALL"')
        end

        it 'correctly handles an KEYS_ONLY projection type' do
          params = 'Model:hkey{uuid},proj_type{KEYS_ONLY}'

          expect do
            SecondaryIndex.parse(params)
          end.to raise_error(NotImplementedError)
        end

        it 'correctly handles an INCLUDE projection type' do
          params = 'Model:hkey{uuid},proj_type{INCLUDE}'

          expect do
            SecondaryIndex.parse(params)
          end.to raise_error(NotImplementedError)
        end

        it 'handles invalid projection type types' do
          params = 'Model:hkey{uuid},proj_type{INCLUDES}'

          expect do
            SecondaryIndex.parse(params)
          end.to raise_error(ArgumentError)
        end
      end
    end
  end
end
