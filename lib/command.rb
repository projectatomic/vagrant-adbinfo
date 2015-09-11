module VagrantPlugins
  module DockerInfo
    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'provides the IP address:port and tls certificate file location for a docker daemon'
      end

      def execute
        with_target_vms(nil, {:single_target=>true}) do |machine|
          port = machine.provider.capability(:forwarded_ports).index(2376)
          message =
                <<-eos
Set the following environment variables to enable access to the
docker daemon running inside of the vagrant virtual machine:

export DOCKER_HOST=tcp://127.0.0.1:#{port}
export DOCKER_CERT_PATH=PATH_NEEDED
export DOCKER_TLS_VERIFY=1
export DOCKER_MACHINE_NAME=\"#{machine.id}\"
                eos
          @env.ui.info(message)
        end
      end
    end
  end
end
