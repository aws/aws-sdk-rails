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
            # Stub execute call to avoid invoking Active Job callbacks
            # Local testing indicates this failure results in a NameError
            allow(::ActiveJob::Base).to receive(:execute).and_raise(NameError)

            expect(response[0]).to eq(500)
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
