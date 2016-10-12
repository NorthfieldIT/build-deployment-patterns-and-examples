# encoding: utf-8
require 'northfield_scripts/core'
require 'shellwords'

# Base class for creating a command.
class Command
  attr_accessor :working_directory

  def initialize(command_name, tee_phabricator = true)
    @command_name = command_name
    @working_directory = Dir.pwd
    @args = []
    @env_vars = {}
    @tee_phabricator = tee_phabricator
  end

  def arg(argument)
    @args << argument
  end

  def env_var(key, val)
    # this is set for boolean values
    @env_vars[key] = val.to_s
  end

  def run(arguments = [])
    Dir.chdir(@working_directory) do
      phabricator_comment_file = NorthfieldScripts.settings['phabricator']['comment_file']
      tee_phabricator = NorthfieldScripts.settings['phabricator']['tee_phabricator'] && @tee_phabricator

      @args += arguments

      @args << "| tee -a #{phabricator_comment_file}" if tee_phabricator

      command_w_params = "\"#{@command_name}\" #{@args.join(' ')}"
      escaped_command = Shellwords.escape("set -o pipefail; #{command_w_params}")

      # you may be asking why bash -c is set here? Well let me tell you! system essentially uses bin/sh under the hood.
      # For most systems, this works A.O.K. On Ubuntu like systems, bin/sh is symlinked to dash which does not like
      # pipefail. bash -c will force the usage of bash over everything.
      # We follow the princinples of B.R.E.A.M => Bash Rules Everything Around Me
      #
      # http://stackoverflow.com/questions/1239510/how-do-i-specify-the-shell-to-use-for-a-ruby-system-call
      # http://greyblake.com/blog/2013/09/21/how-to-call-bash-not-shell-from-ruby/
      command_output = system(@env_vars, "bash -c #{escaped_command}")

      raise "#{@command_name} failed. Check the above messages." unless command_output
    end
  end
end
