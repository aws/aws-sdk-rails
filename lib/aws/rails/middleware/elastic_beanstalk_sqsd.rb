# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      # Middleware to handle requests from the SQS Daemon present on Elastic Beanstalk worker environments.
      class ElasticBeanstalkSQSD
        def initialize(app)
          @app = app
          @logger = ::Rails.logger
        end

        def call(env)
          request = ::ActionDispatch::Request.new(env)

          # Pass through unless user agent is the SQS Daemon
          return @app.call(env) unless from_sqs_daemon?(request)

          @logger.debug('aws-sdk-rails middleware detected call from Elastic Beanstalk SQS Daemon.')

          # Only accept requests from this user agent if it is from localhost or a docker host in case of forgery.
          unless request.local? || sent_from_docker_host?(request)
            @logger.warn('SQSD request detected from untrusted address; returning 403 forbidden.')
            return forbidden_response
          end

          # Execute job or periodic task based on HTTP request context
          periodic_task?(request) ? execute_periodic_task(request) : execute_job(request)
        end

        private

        def execute_job(request)
          # Jobs queued from the Active Job SQS adapter contain the JSON message in the request body.
          job = Aws::Json.load(request.body.string)
          job_name = job['job_class']
          @logger.debug("Executing job: #{job_name}")

          begin
            ::ActiveJob::Base.execute(job)
          rescue NameError => e
            @logger.error("Job #{job_name} could not resolve to a class that inherits from Active Job.")
            @logger.error("Error: #{e}")
            return internal_error_response
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
            @logger.error("Periodic task #{job_name} could not resolve to an Active Job class - check the spelling in cron.yaml.")
            @logger.error("Error: #{e}.")
            return internal_error_response
          end

          [200, { 'Content-Type' => 'text/plain' }, ["Successfully ran periodic task #{job_name}."]]
        end

        def internal_error_response
          message = 'Failed to execute job - see Rails log for more details.'
          [500, { 'Content-Type' => 'text/plain' }, [message]]
        end

        def forbidden_response
          message = 'Request with aws-sqsd user agent was made from untrusted address.'
          [403, { 'Content-Type' => 'text/plain' }, [message]]
        end

        # The beanstalk worker SQS Daemon sets a specific User-Agent headers that begins with 'aws-sqsd'.
        def from_sqs_daemon?(request)
          current_user_agent = request.headers['User-Agent']

          !current_user_agent.nil? && current_user_agent.start_with?('aws-sqsd')
        end

        # The beanstalk worker SQS Daemon will add the custom 'X-Aws-Sqsd-Taskname' header
        # for periodic tasks set in cron.yaml.
        def periodic_task?(request)
          !request.headers['X-Aws-Sqsd-Taskname'].nil? && request.headers['X-Aws-Sqsd-Taskname'].present?
        end

        def sent_from_docker_host?(request)
          app_runs_in_docker_container? && ip_originates_from_docker_host?(request)
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

        def ip_originates_from_docker_host?(request)
          default_docker_ips.include?(request.remote_ip) ||
            default_docker_ips.include?(request.remote_addr)
        end

        def default_docker_ips
          @default_docker_ips ||= build_default_docker_ips
        end

        def build_default_docker_ips
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
