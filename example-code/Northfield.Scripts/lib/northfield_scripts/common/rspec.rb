# encoding: utf-8
require 'northfield_scripts/common/commands/rspec_command'

# Interface for Rspec
class Rspec
  def self.run(options)
    cmd = RspecCommand.new
    cmd.run options
  end
end
