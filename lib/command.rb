require 'open3'

module OS

  def OS.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
    !OS.Windows?
  end

  def OS.linux?
    OS.unix? and not OS.mac?
  end

end

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
              # Find the ssh information
              hIP = machine.ssh_info[:host]
              hport = machine.ssh_info[:port]
              husername = machine.ssh_info[:username]

	      if !OS.windows? then
                hprivate_key_path = machine.ssh_info[:private_key_path][0]
                # scp over the client side certs from guest to host machine
                `scp -r -P #{hport} -o LogLevel=FATAL -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i #{hprivate_key_path} #{husername}@#{hIP}:/home/vagrant/.docker #{secrets_path}`
              else
	        `pscp -r -P #{hport} -q -batch -pw vagrant #{husername}@#{hIP}:/home/vagrant/.docker #{secrets_path}`
              end

          end

          # Print configuration information for accesing the docker daemon

          # Finds the host machine port forwarded from guest docker
           port = machine.provider.capability(:forwarded_ports).key(2376)
	   guest_ip = "127.0.0.1"

          message =
                <<-eos
Set the following environment variables to enable access to the
docker daemon running inside of the vagrant virtual machine:

export DOCKER_HOST=tcp://#{guest_ip}:#{port}
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
