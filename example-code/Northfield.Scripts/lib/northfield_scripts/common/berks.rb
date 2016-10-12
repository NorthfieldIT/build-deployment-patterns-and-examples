# encoding: utf-8
require 'northfield_scripts/common/commands/berks_command'
require 'northfield_scripts/core'

# Interface for Berks
class Berks
  def self.install(options)
    cmd = BerksCommand.new
    cmd.arg 'install'
    cmd.run options
  end

  def self.upload(cookbook)
    pipe = IO.popen("berks upload #{cookbook}")
    while (line = pipe.gets)
      NorthfieldScripts.logger.puts line
      raise "This #{cookbook} cookbook version has already been uploaded. Please bump the version. Error: #{line}" if line.include?('(frozen)') && line.include?(cookbook)
    end
  end
end
