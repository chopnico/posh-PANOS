# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'socket'

Vagrant.configure("2") do |config|
  config.vm.box = "igs/panos"
  config.ssh.insert_key = false
  config.vm.boot_timeout = 60
  config.vm.graceful_halt_timeout = 60
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.trigger.after :up do |trigger|
    case RUBY_PLATFORM
    when /win32/
    when /linux/
      trigger.info = "Starting SSH proxy..."
      trigger.run = { path: 'bin/start-ssh-proxy'}
      trigger.info = "Started SSH proxy."
    when /darwin/
      trigger.run = { path: 'bin/start-ssh-proxy'}
      trigger.info = "Started SSH proxy."
    end
  end

  config.trigger.after :destroy, :halt do |trigger|
    case RUBY_PLATFORM
    when /win32/
    when /linux/
      trigger.info = "Stopping SSH proxy..."
      trigger.run = { path: 'bin/stop-ssh-proxy'}
      trigger.info = "Stopped SSH proxy."
    when /darwin/
      trigger.info = "Stopping SSH proxy..."
      trigger.run = { path: 'bin/stop-ssh-proxy'}
      trigger.info = "Stopped SSH proxy."
    end
  end
end
