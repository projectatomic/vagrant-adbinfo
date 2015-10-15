module VagrantPlugins
  module DockerInfo
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'provides the IP address:port and tls certificate file location for a docker daemon'
      end

      def execute
        with_target_vms(nil, {:single_target=>true}) do |machine|
          # Path to the private_key and where we will store the TLS Certificates
          secrets_path = machine.data_dir

          # First, get the TLS Certificates, if needed
          if !File.directory?(File.expand_path(".docker", secrets_path)) then
              # Finds the host machine port forwarded from guest sshd
              hport = machine.provider.capability(:forwarded_ports).key(22)

              # scp over the client side certs from guest to host machine
              `scp -r -P #{hport} -o LogLevel=FATAL -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{secrets_path}/private_key vagrant@127.0.0.1:/home/vagrant/.docker #{secrets_path}`
          end

          # Print configuration information for accesing the docker daemon

          # Finds the host machine port forwarded from guest docker
           port = machine.provider.capability(:forwarded_ports).key(2376)
          message =
                <<-eos
Set the following environment variables to enable access to the
docker daemon running inside of the vagrant virtual machine:

export DOCKER_HOST=tcp://127.0.0.1:#{port}
export DOCKER_CERT_PATH=#{secrets_path}/.docker
export DOCKER_TLS_VERIFY=1
export DOCKER_MACHINE_NAME=#{machine.index_uuid[0..6]}
                eos
          @env.ui.info(message)
        end
      end
    end
  end
end
