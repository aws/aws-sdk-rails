require 'test_helper'
require_relative 'elastic_beanstalk_job'
require_relative 'elastic_beanstalk_periodic_task'

module Aws
  module Rails
    describe EbsSqsActiveJobMiddleware do
      # Simple mock Rack app that always returns 200
      let(:mock_rack_app) { ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

      let(:logger) { double(error: nil, debug: nil, warn: nil) }

      it 'passes request through if user-agent is not SQS Daemon' do
        mock_rack_env = create_mock_env('127.0.0.1', 'not-aws-sqsd')

        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(200)
        expect(response[2]).to eq(['OK'])
      end

      it 'returns forbidden when called from untrusted source' do
        mock_rack_env = create_mock_env('1.2.3.4', 'aws-sqsd/1.1')

        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(403)
      end

      it 'successfully invokes job when passed through request body' do
        # Stub execute call to avoid invoking Active Job callbacks
        expect(ActiveJob::Base).to receive(:execute).and_return(nil)
        mock_rack_env = create_mock_env('::1', 'aws-sqsd/1.1')

        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(200)
        expect(response[1]['Content-Type']).to eq('text/plain')
        expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
      end

      it 'returns internal server error if job name cannot be resolved' do
        # Stub execute call to avoid invoking Active Job callbacks
        # Local testing indicates this failure results in a NameError
        allow(ActiveJob::Base).to receive(:execute).and_raise(NameError)
        mock_rack_env = create_mock_env('::1', 'aws-sqsd/1.1')

        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(500)
      end

      it 'successfully invokes periodic task when passed through custom header' do
        mock_rack_env = create_mock_env('127.0.0.1', 'aws-sqsd/1.1', true)
        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)

        expect_any_instance_of(ElasticBeanstalkPeriodicTask).to receive(:perform_now)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(200)
        expect(response[1]['Content-Type']).to eq('text/plain')
        expect(response[2]).to eq(['Successfully ran periodic task ElasticBeanstalkPeriodicTask.'])
      end

      it 'returns internal server error if periodic task cannot be resolved' do
        mock_rack_env = create_mock_env('127.0.0.1', 'aws-sqsd/1.1', true)
        mock_rack_env['HTTP_X_AWS_SQSD_TASKNAME'] = 'NonExistentTask'

        test_middleware = EbsSqsActiveJobMiddleware.new(mock_rack_app)
        response = test_middleware.call(mock_rack_env)

        expect(response[0]).to eq(500)
      end

      # Create a minimal mock Rack environment hash to test just what we need
      def create_mock_env(source_ip, user_agent, is_periodic_task = false)
        mock_env = {
          'REMOTE_ADDR' => source_ip,
          'HTTP_USER_AGENT' => user_agent
        }

        if is_periodic_task
          mock_env['HTTP_X_AWS_SQSD_TASKNAME'] = 'ElasticBeanstalkPeriodicTask'
        else
          mock_env['rack.input'] = StringIO.new('{"job_class": "ElasticBeanstalkJob"}')
        end

        mock_env
      end
    end
  end
end
