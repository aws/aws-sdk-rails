# frozen_string_literal: true

module Aws
  module Rails
    module Middleware
      class ElasticBeanstalkSQSDTest < ActiveSupport::TestCase
        # Simple mock Rack app that always returns 200
        let(:mock_rack_app) { ->(_) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

        let(:logger) { double(error: nil, debug: nil, warn: nil) }

        # Create a minimal mock Rack environment hash to test just what we need
        def create_mock_env(source_ip, user_agent, is_periodic_task: false)
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

        it 'passes request through if user-agent is not SQS Daemon' do
          mock_rack_env = create_mock_env('127.0.0.1', 'not-aws-sqsd')

          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[2]).to eq(['OK'])
        end

        it 'returns forbidden when called from untrusted source' do
          mock_rack_env = create_mock_env('1.2.3.4', 'aws-sqsd/1.1')

          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(403)
        end

        it 'successfully invokes job when passed through request body' do
          # Stub execute call to avoid invoking Active Job callbacks
          expect(::ActiveJob::Base).to receive(:execute).and_return(nil)
          mock_rack_env = create_mock_env('::1', 'aws-sqsd/1.1')

          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
        end

        it 'returns internal server error if job name cannot be resolved' do
          # Stub execute call to avoid invoking Active Job callbacks
          # Local testing indicates this failure results in a NameError
          allow(::ActiveJob::Base).to receive(:execute).and_raise(NameError)
          mock_rack_env = create_mock_env('::1', 'aws-sqsd/1.1')

          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(500)
        end

        it 'successfully invokes periodic task when passed through custom header' do
          mock_rack_env = create_mock_env('127.0.0.1', 'aws-sqsd/1.1', is_periodic_task: true)
          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)

          expect_any_instance_of(ElasticBeanstalkPeriodicTask).to receive(:perform_now)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran periodic task ElasticBeanstalkPeriodicTask.'])
        end

        it 'returns internal server error if periodic task cannot be resolved' do
          mock_rack_env = create_mock_env('127.0.0.1', 'aws-sqsd/1.1', is_periodic_task: true)
          mock_rack_env['HTTP_X_AWS_SQSD_TASKNAME'] = 'NonExistentTask'

          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)
          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(500)
        end

        it 'successfully invokes job when docker default gateway ip is changed' do
          mock_rack_env = create_mock_env('192.168.176.1', 'aws-sqsd/1.1', is_periodic_task: false)
          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)

          proc_net_route = <<~CONTENT
            Iface\tDestination\tGateway\tFlags\tRefCnt\tUse\tMetric\tMask\tMTU\tWindow\tIRTT
            eth0\t00000000\t01B0A8C0\t0003\t0\t0\t0\t00000000\t0\t0\t0
            eth0\t00B0A8C0\t00000000\t0001\t0\t0\t0\t00F0FFFF\t0\t0\t0
          CONTENT

          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:open).and_call_original

          expect(File).to receive(:exist?).with('/proc/net/route').and_return(true)
          expect(File).to receive(:open).with('/proc/net/route').and_return(StringIO.new(proc_net_route))
          expect(test_middleware).to receive(:app_runs_in_docker_container?).and_return(true)

          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
        end

        it 'successfully invokes job when /proc/net/route does not exist' do
          mock_rack_env = create_mock_env('172.17.0.1', 'aws-sqsd/1.1', is_periodic_task: false)
          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)

          allow(File).to receive(:exist?).and_call_original

          expect(File).to receive(:exist?).with('/proc/net/route').and_return(false)
          expect(test_middleware).to receive(:app_runs_in_docker_container?).and_return(true)

          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
        end

        it 'successfully invokes job in docker container with cgroup1' do
          mock_rack_env = create_mock_env('172.17.0.1', 'aws-sqsd/1.1', is_periodic_task: false)
          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)

          proc_1_cgroup = <<~CONTENT
            13:rdma:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            12:hugetlb:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            11:memory:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            10:devices:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
            9:blkio:/docker/d59538e9b3d3aa6012f08587c13199cbad3f882ecaa9637905971df18ab89757
          CONTENT

          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:read).and_call_original

          expect(File).to receive(:exist?).with('/proc/1/cgroup').and_return(true)
          expect(File).to receive(:read).with('/proc/1/cgroup').and_return(proc_1_cgroup)

          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
        end

        it 'successfully invokes job in docker container with cgroup2' do
          mock_rack_env = create_mock_env('172.17.0.1', 'aws-sqsd/1.1', is_periodic_task: false)
          test_middleware = ElasticBeanstalkSQSD.new(mock_rack_app)

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

          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:read).and_call_original

          expect(File).to receive(:exist?).with('/proc/1/cgroup').and_return(true)
          expect(File).to receive(:read).with('/proc/1/cgroup').and_return(proc_1_cgroup)
          expect(File).to receive(:exist?).with('/proc/self/mountinfo').and_return(true)
          expect(File).to receive(:read).with('/proc/self/mountinfo').and_return(proc_self_mountinfo)

          response = test_middleware.call(mock_rack_env)

          expect(response[0]).to eq(200)
          expect(response[1]['Content-Type']).to eq('text/plain')
          expect(response[2]).to eq(['Successfully ran job ElasticBeanstalkJob.'])
        end
      end
    end
  end
end
