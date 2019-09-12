# -*- mode: ruby -*-
# vi: set ft=ruby :

class Panos < Vagrant.plugin("2")
  name "Panos"
  def detect?(machine)
    machine.communicate.test("show version")
  end
end

Vagrant.configure("2") do |config|
  Panos
  config.vm.box = "igs/panos"
  config.ssh.insert_key = false
  config.vm.boot_timeout = 60
  config.vm.graceful_halt_timeout = 60
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.network "forwarded_port", guest: 443, host: 2244
end
