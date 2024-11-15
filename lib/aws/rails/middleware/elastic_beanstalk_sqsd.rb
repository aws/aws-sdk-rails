# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      # Middleware to handle requests from the SQS Daemon present on Elastic Beanstalk worker environments.
      class ElasticBeanstalkSQSD
        INTERNAL_ERROR_MESSAGE = 'Failed to execute job - see Rails log for more details.'
        # TODO - move these away from constants so they don't have to be frozen
        INTERNAL_ERROR_RESPONSE = [500, { 'Content-Type' => 'text/plain' }, [INTERNAL_ERROR_MESSAGE]].freeze
        FORBIDDEN_MESSAGE = 'Request with aws-sqsd user agent was made from untrusted address.'
        FORBIDDEN_RESPONSE = [403, { 'Content-Type' => 'text/plain' }, [FORBIDDEN_MESSAGE]].freeze

        def initialize(app)
          @app = app
          @logger = ::Rails.logger
        end

        def call(env)
          request = ::ActionDispatch::Request.new(env)
          return @app.call(env) unless from_sqs_daemon?(request)

          @logger.debug('aws-sdk-rails middleware detected a call from the Elastic Beanstalk SQS Daemon.')

          # Only accept requests from this user agent if it is from localhost or a docker host in case of forgery.
          unless request.local? || sent_from_docker_host?(request)
            @logger.warn("SQSD request detected from untrusted address #{request.ip}; returning 403 forbidden.")
            return FORBIDDEN_RESPONSE
          end

          periodic_task?(request) ? execute_periodic_task(request) : execute_job(request)
        end

        private

        def execute_job(request)
          job = Aws::Json.load(request.body.string)
          job_name = job['job_class']
          @logger.debug("Executing job: #{job_name}")

          begin
            ::ActiveJob::Base.execute(job)
          rescue NameError => e
            @logger.error("Job #{job_name} could not resolve to an Active Job class.")
            @logger.error("Error: #{e}")
            return INTERNAL_ERROR_RESPONSE
          end

          [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran job #{job_name}."]]
        end

        def execute_periodic_task(request)
          # The beanstalk worker SQS Daemon will add the 'X-Aws-Sqsd-Taskname' for periodic tasks set in cron.yaml.
          job_name = request.headers['X-Aws-Sqsd-Taskname']
          @logger.debug("Creating and executing periodic task: #{job_name}")

          begin
            job = job_name.constantize.new
            job.perform_now
          rescue NameError => e
            @logger.error("Periodic task #{job_name} could not resolve to an Active Job class.")
            @logger.error("Error: #{e}.")
            return INTERNAL_ERROR_RESPONSE
          end

          [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran periodic task #{job_name}."]]
        end

        # The beanstalk worker SQS Daemon sets a specific User-Agent headers that begins with 'aws-sqsd'.
        def from_sqs_daemon?(request)
          current_user_agent = request.headers['User-Agent']

          !current_user_agent.nil? && current_user_agent.start_with?('aws-sqsd')
        end

        # The beanstalk worker SQS Daemon will add the custom 'X-Aws-Sqsd-Taskname' header for periodic tasks set in cron.yaml.
        def periodic_task?(request)
          !request.headers['X-Aws-Sqsd-Taskname'].nil? && request.headers['X-Aws-Sqsd-Taskname'].present?
        end

        def sent_from_docker_host?(request)
          app_runs_in_docker_container? && default_gw_ips.include?(request.ip)
        end

        def app_runs_in_docker_container?
          @app_runs_in_docker_container ||= in_docker_container_with_cgroup1? || in_docker_container_with_cgroup2?
        end

        def in_docker_container_with_cgroup1?
          File.exist?('/proc/1/cgroup') && File.read('/proc/1/cgroup') =~ %r{/docker/}
        end

        def in_docker_container_with_cgroup2?
          File.exist?('/proc/self/mountinfo') && File.read('/proc/self/mountinfo') =~ %r{/docker/containers/}
        end

        def default_gw_ips
          default_gw_ips = ['172.17.0.1']

          if File.exist?('/proc/net/route')
            File.open('/proc/net/route').each_line do |line|
              fields = line.strip.split
              next if fields.size != 11

              # Destination == 0.0.0.0 and Flags & RTF_GATEWAY != 0
              next unless fields[1] == '00000000' && fields[3].hex.anybits?(0x2)

              default_gw_ips << IPAddr.new_ntoh([fields[2].hex].pack('L')).to_s
            end
          end

          default_gw_ips
        end
      end
    end
  end
end
