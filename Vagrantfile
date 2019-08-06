# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "igs/panos"
  config.ssh.insert_key = false
  config.vm.boot_timeout = 60
  config.vm.graceful_halt_timeout = 60
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.network "forwarded_port", guest: 443, host: 2244
end
