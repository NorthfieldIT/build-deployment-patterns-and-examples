# encoding: utf-8
require 'northfield_scripts/core'
require 'northfield_scripts/common/command'

# Generic runner. Think Travis CI
class GenericRunner
  def self.run_shell_def(shell_def)
    cmd = Command.new shell_def.shift
    cmd.run shell_def
  end

  def self.run_command(command)
    cmd = create_command command
    cmd.run
  end

  def self.run_command_with_env(command)
    cmd = create_command command['command']
    command['env_vars'] ||= {}
    command['env_vars'].each do |key, value|
      cmd.env_var(key, value)
    end
    cmd.run
  end

  def self.create_command(command)
    command_and_args = command.split(' ')
    cmd = Command.new command_and_args.shift
    command_and_args.each do |arg|
      cmd.arg arg
    end
    cmd
  end
end
