# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      describe ElasticBeanstalkSQSD do
        subject(:response) do
          mock_rack_env = create_mock_env
          test_middleware = described_class.new(mock_rack_app)
          test_middleware.call(mock_rack_env)
        end

        # Simple mock Rack app that always returns 200
        let(:mock_rack_app) { ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

        let(:logger) { double(error: nil, debug: nil, warn: nil) }
        let(:user_agent) { 'aws-sqsd/1.1' }
        let(:remote_ip) { '127.0.0.1' }
        let(:remote_addr) { nil }
        let(:is_periodic_task) { nil }
        let(:period_task_name) { 'ElasticBeanstalkPeriodicTask' }

        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:open).and_call_original
        end

        shared_examples_for 'passes request through' do
          it 'passes request' do
            expect(response[0]).to eq(200)
            expect(response[2]).to eq(['OK'])
          end
        end

        shared_examples_for 'runs job' do
          it 'invokes job' do
            expect(response[0]).to eq(200)
            expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
          end

          it 'returns internal server error if job name cannot be resolved' do
            mock_env = create_mock_env
            mock_env['rack.input'] = StringIO.new('{"job_class": "NoSuchJobClass"}')
            test_middleware = described_class.new(mock_rack_app)
            expect(test_middleware.call(mock_env)[0]).to eq(500)
          end

          context 'when user-agent is not sqs daemon' do
            let(:user_agent) { 'not-aws-sqsd' }

            include_examples 'passes request through'
          end

          context 'when periodic task' do
            let(:is_periodic_task) { true }

            it 'successfully invokes periodic task when passed through custom header' do
              expect(response[0]).to eq(200)
              expect(response[1]['Content-Type']).to eq('text/plain')
              expect(response[2]).to eq(['Successfully ran periodic task ElasticBeanstalkPeriodicTask.'])
            end

            context 'when unknown periodic task name' do
              let(:period_task_name) { 'NonExistentTask' }

              it 'returns internal server error' do
                expect(response[0]).to eq(500)
              end
            end
          end
        end

        shared_examples_for 'is forbidden' do
          it 'passes request' do
            expect(response[0]).to eq(403)
          end

          context 'when user-agent is not sqs daemon' do
            let(:user_agent) { 'not-aws-sqsd' }

            include_examples 'passes request through'
          end
        end

        context 'when local IP' do
          let(:remote_ip) { '127.0.0.1' }

          include_examples 'runs job'
        end

        context 'when ::1 IP' do
          let(:remote_ip) { '::1' }

          include_examples 'runs job'
        end

        context 'when non-local IP' do
          let(:remote_ip) { '1.2.3.4' }

          include_examples 'is forbidden'
        end

        shared_examples_for 'is valid in either cgroup1 or cgroup2' do
          context 'when not in a docker container' do
            before { stub_runs_in_neither_docker_container }

            include_examples 'is forbidden'
          end

          context 'when docker container cgroup1' do
            before { stub_runs_in_docker_container_cgroup1 }

            include_examples 'runs job'
          end

          context 'when docker container cgroup2' do
            before { stub_runs_in_docker_container_cgroup2 }

            include_examples 'runs job'
          end
        end

        shared_examples_for 'is invalid in either cgroup1 or cgroup2' do
          context 'when not in a docker container' do
            before { stub_runs_in_neither_docker_container }

            include_examples 'is forbidden'
          end

          context 'when docker container cgroup1' do
            before { stub_runs_in_docker_container_cgroup1 }

            include_examples 'is forbidden'
          end

          context 'when docker container cgroup2' do
            before { stub_runs_in_docker_container_cgroup2 }

            include_examples 'is forbidden'
          end
        end

        context 'when remote ip is invalid, but remote_addr is docker gw' do
          let(:remote_addr) { '172.17.0.1' }
          let(:remote_ip) { '192.168.176.1' }

          include_examples 'is valid in either cgroup1 or cgroup2'

          it 'successfully invokes job when /proc/net/route does not exist' do
            expect(File).to receive(:exist?).with('/proc/net/route').and_return(false)

            stub_runs_in_docker_container_cgroup2

            expect(response[0]).to eq(200)
            expect(response[1]['Content-Type']).to eq('text/plain')
            expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
          end
        end

        context 'when remote addr is non-standard ip but in /proc/net/route' do
          let(:remote_addr) { '192.168.176.1' }

          before do
            proc_net_route = <<~CONTENT
              Iface\tDestination\tGateway\tFlags\tRefCnt\tUse\tMetric\tMask\tMTU\tWindow\tIRTT
              eth0\t00000000\t01B0A8C0\t0003\t0\t0\t0\t00000000\t0\t0\t0
              eth0\t00B0A8C0\t00000000\t0001\t0\t0\t0\t00F0FFFF\t0\t0\t0
            CONTENT

            allow(File).to receive(:exist?).with('/proc/net/route').and_return(true)
            allow(File).to receive(:open).with('/proc/net/route').and_return(StringIO.new(proc_net_route))
          end

          include_examples 'is valid in either cgroup1 or cgroup2'
        end

        context 'when remote ip is non-standard ip but in /proc/net/route' do
          let(:remote_ip) { '192.168.176.1' }

          before do
            proc_net_route = <<~CONTENT
              Iface\tDestination\tGateway\tFlags\tRefCnt\tUse\tMetric\tMask\tMTU\tWindow\tIRTT
              eth0\t00000000\t01B0A8C0\t0003\t0\t0\t0\t00000000\t0\t0\t0
              eth0\t00B0A8C0\t00000000\t0001\t0\t0\t0\t00F0FFFF\t0\t0\t0
            CONTENT

            allow(File).to receive(:exist?).with('/proc/net/route').and_return(true)
            allow(File).to receive(:open).with('/proc/net/route').and_return(StringIO.new(proc_net_route))
          end

          include_examples 'is valid in either cgroup1 or cgroup2'
        end

        context 'when remote addr is non-standard ip but not in /proc/net/route' do
          let(:remote_addr) { '192.168.176.1' }

          before do
            proc_net_route = <<~CONTENT
              Iface\tDestination\tGateway\tFlags\tRefCnt\tUse\tMetric\tMask\tMTU\tWindow\tIRTT
            CONTENT

            allow(File).to receive(:exist?).with('/proc/net/route').and_return(true)
            allow(File).to receive(:open).with('/proc/net/route').and_return(StringIO.new(proc_net_route))
          end

          include_examples 'is invalid in either cgroup1 or cgroup2'
        end

        context 'when remote ip is default docker gw' do
          let(:remote_ip) { '172.17.0.1' }

          include_examples 'is valid in either cgroup1 or cgroup2'
        end

        context 'when remote addr is default docker gw' do
          let(:remote_addr) { '172.17.0.1' }

          include_examples 'is valid in either cgroup1 or cgroup2'
        end

        context 'job class validation' do
          let(:remote_ip) { '127.0.0.1' }

          def response_for(class_name)
            mock_env = create_mock_env
            mock_env['rack.input'] = StringIO.new(ActiveSupport::JSON.dump('job_class' => class_name))
            described_class.new(mock_rack_app).call(mock_env)
          end

          it 'rejects classes that do not inherit from ActiveJob::Base' do
            expect(response_for('String')[0]).to eq(500)
          end

          it 'rejects names that are not well-formed constant paths' do
            ['', 'elastic_beanstalk_job', 'ElasticBeanstalkJob; puts 1', 'Elastic Beanstalk', '@job'].each do |name|
              expect(response_for(name)[0]).to eq(500)
            end
          end

          it 'does not resolve a name through an ancestor of the namespace' do
            # ElasticBeanstalkJob does not define CallbackChain, but its
            # ancestors do, so an inheriting lookup would resolve this to
            # ActiveSupport::Callbacks::CallbackChain. Such a constant fails
            # the ActiveJob::Base check regardless, so this asserts on the
            # resolution itself: names must not reach outside the namespace
            # they appear to address.
            middleware = described_class.new(mock_rack_app)
            expect { middleware.send(:resolve_job_class, 'ElasticBeanstalkJob::CallbackChain') }
              .to raise_error(NameError)
          end

          it 'does not resolve the constant when the name is malformed' do
            expect_any_instance_of(described_class).not_to receive(:constantize_job_class)
            expect(response_for('not_a_class_name')[0]).to eq(500)
          end

          context 'with job_class_allowlist configured' do
            before { described_class.config.job_class_allowlist = [ElasticBeanstalkJob] }
            after { described_class.config.job_class_allowlist = nil }

            it 'allows classes in the allowlist' do
              expect(response[0]).to eq(200)
            end

            it 'rejects classes not in the allowlist' do
              expect(response_for('ElasticBeanstalkPeriodicTask')[0]).to eq(500)
            end

            it 'rejects a disallowed name without resolving its constant' do
              # Resolving is what triggers autoloading, so a name the allowlist
              # excludes must be rejected before the lookup happens.
              expect_any_instance_of(described_class).not_to receive(:constantize_job_class)
              expect(response_for('ElasticBeanstalkPeriodicTask')[0]).to eq(500)
            end

            it 'rejects a disallowed name even when it is undefined' do
              expect(response_for('NoSuchJobClass')[0]).to eq(500)
            end

            context 'when the request is a periodic task' do
              let(:is_periodic_task) { true }
              let(:period_task_name) { 'ElasticBeanstalkPeriodicTask' }

              it 'rejects a disallowed task without resolving its constant' do
                # The task name comes from a request header, so the periodic
                # path must gate on the allowlist before resolving too.
                expect_any_instance_of(described_class).not_to receive(:constantize_job_class)
                expect(response[0]).to eq(500)
              end
            end

            context 'when the allowlist holds a stale class object (Zeitwerk reload)' do
              # Simulate a Zeitwerk reload: the allowlist was populated at boot
              # with one class object, but the message now resolves to a brand-
              # new object with the same name. Matching by object identity would
              # reject it; matching by name must still accept it.
              let(:stale_class) do
                Class.new(ElasticBeanstalkJob.superclass).tap do |klass|
                  allow(klass).to receive(:name).and_return('ElasticBeanstalkJob')
                  allow(klass).to receive(:to_s).and_return('ElasticBeanstalkJob')
                end
              end

              before { described_class.config.job_class_allowlist = [stale_class] }

              it 'still accepts the reloaded, identically-named class' do
                expect(stale_class).not_to equal(ElasticBeanstalkJob)
                expect(response[0]).to eq(200)
              end
            end
          end

          it 'does not mislabel a NameError raised from within a valid job' do
            # A resolvable job whose execution raises NameError (e.g. a typo'd
            # constant in #perform) must not be treated as a class-resolution
            # failure. It should propagate rather than becoming a 500 logged as
            # "could not resolve to a class".
            allow(::ActiveJob::Base).to receive(:execute)
              .and_raise(NameError, 'uninitialized constant TypoedConstant')
            expect { response }.to raise_error(NameError, /TypoedConstant/)
          end
        end

        context 'when AWS_PROCESS_BEANSTALK_WORKER_JOBS_ASYNC' do
          before(:each) do
            ENV['AWS_PROCESS_BEANSTALK_WORKER_JOBS_ASYNC'] = 'true'
          end

          after(:each) do
            ENV.delete('AWS_PROCESS_BEANSTALK_WORKER_JOBS_ASYNC')
          end

          it 'queues job' do
            expect_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:post)
            expect(response[0]).to eq(200)
            expect(response[2]).to eq(['Successfully queued job ElasticBeanstalkJob'])
          end

          context 'no capacity' do
            it 'returns too many requests error' do
              allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:post)
                .and_raise Concurrent::RejectedExecutionError

              expect(response[0]).to eq(429)
            end
          end

          context 'periodic task' do
            let(:is_periodic_task) { true }

            it 'queues job' do
              expect_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:post)
              expect(response[0]).to eq(200)
              expect(response[2]).to eq(['Successfully queued periodic task ElasticBeanstalkPeriodicTask'])
            end

            context 'no capacity' do
              it 'returns too many requests error' do
                allow_any_instance_of(Concurrent::ThreadPoolExecutor).to receive(:post)
                  .and_raise Concurrent::RejectedExecutionError

                expect(response[0]).to eq(429)
              end
            end
          end
        end

        def stub_runs_in_neither_docker_container
          proc_1_cgroup = <<~CONTENT
            0::/
          CONTENT

          proc_self_mountinfo = <<~CONTENT
            355 354 0:21 / /sys/fs/cgroup ro,nosuid,nodev,noexec,relatime - cgroup2 cgroup rw,nsdelegate
            356 352 0:74 / /dev/mqueue rw,nosuid,nodev,noexec,relatime - mqueue mqueue rw
            357 352 0:79 / /dev/shm rw,nosuid,nodev,noexec,relatime - tmpfs shm rw,size=65536k
            316 352 0:77 /0 /dev/console rw,nosuid,noexec,relatime - devpts devpts rw,gid=5,mode=620,ptmxmode=666
          CONTENT

          allow(File).to receive(:exist?).with('/proc/1/cgroup').and_return(true)
          allow(File).to receive(:read).with('/proc/1/cgroup').and_return(proc_1_cgroup)
          allow(File).to receive(:exist?).with('/proc/self/mountinfo').and_return(true)
          allow(File).to receive(:read).with('/proc/self/mountinfo').and_return(proc_self_mountinfo)
        end

        def stub_runs_in_docker_container_cgroup1
          proc_1_cgroup = <<~CONTENT
            13:rdma:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            12:hugetlb:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            11:memory:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            10:devices:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            9:blkio:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
          CONTENT
          allow(File).to receive(:exist?).with('/proc/1/cgroup').and_return(true)
          allow(File).to receive(:read).with('/proc/1/cgroup').and_return(proc_1_cgroup)
        end

        def stub_runs_in_docker_container_cgroup2
          proc_1_cgroup = <<~CONTENT
            0::/
          CONTENT

          proc_self_mountinfo = <<~CONTENT
            355 354 0:21 / /sys/fs/cgroup ro,nosuid,nodev,noexec,relatime - cgroup2 cgroup rw,nsdelegate
            356 352 0:74 / /dev/mqueue rw,nosuid,nodev,noexec,relatime - mqueue mqueue rw
            357 352 0:79 / /dev/shm rw,nosuid,nodev,noexec,relatime - tmpfs shm rw,size=65536k
            358 350 8:16 /var/lib/docker/containers/69e3febd00ac4720d2ea58c935574776285f6a0016d2aa30b0c280a81c385e69/resolv.conf /etc/resolv.conf rw,relatime - ext4 /dev/sdb rw,discard,errors=remount-ro,data=ordered
            359 350 8:16 /var/lib/docker/containers/69e3febd00ac4720d2ea58c935574776285f6a0016d2aa30b0c280a81c385e69/hostname /etc/hostname rw,relatime - ext4 /dev/sdb rw,discard,errors=remount-ro,data=ordered
            360 350 8:16 /var/lib/docker/containers/69e3febd00ac4720d2ea58c935574776285f6a0016d2aa30b0c280a81c385e69/hosts /etc/hosts rw,relatime - ext4 /dev/sdb rw,discard,errors=remount-ro,data=ordered
            316 352 0:77 /0 /dev/console rw,nosuid,noexec,relatime - devpts devpts rw,gid=5,mode=620,ptmxmode=666
          CONTENT

          allow(File).to receive(:exist?).with('/proc/1/cgroup').and_return(true)
          allow(File).to receive(:read).with('/proc/1/cgroup').and_return(proc_1_cgroup)
          allow(File).to receive(:exist?).with('/proc/self/mountinfo').and_return(true)
          allow(File).to receive(:read).with('/proc/self/mountinfo').and_return(proc_self_mountinfo)
        end

        # Create a minimal mock Rack environment hash to test just what we need
        def create_mock_env
          mock_env = {
            'HTTP_X_FORWARDED_FOR' => remote_ip,
            'REMOTE_ADDR' => remote_addr || remote_ip,
            'HTTP_USER_AGENT' => user_agent
          }

          if is_periodic_task
            mock_env['PATH_INFO'] = '/'
            mock_env['HTTP_X_AWS_SQSD_TASKNAME'] = period_task_name
          else
            mock_env['rack.input'] = StringIO.new('{"job_class": "ElasticBeanstalkJob"}')
          end

          mock_env
        end
      end
    end
  end
end
