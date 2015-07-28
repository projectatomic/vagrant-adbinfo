module VagrantPlugins
  module DockerInfo
    class Plugin < Vagrant.plugin(2)
      name 'dockerinfo'

      command('dockerinfo', primary: false) do
        require_relative 'command'
        Command
      end
    end
  end
end
