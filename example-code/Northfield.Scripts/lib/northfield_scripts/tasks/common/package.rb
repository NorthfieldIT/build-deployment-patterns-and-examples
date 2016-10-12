# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/common/command'
require 'northfield_scripts/core'

namespace 'common' do
  desc 'Package the working directory'
  task :package do
    TaskLogger.task_block 'Packaging Workspace' do
      cmd = Command.new('tar')
      options = NorthfieldScripts.settings['package']['options']
      optional_files = NorthfieldScripts.settings['package']['optional_files']
      begin
        optional_files.each do |optional_file|
          options << optional_file if File.exist?(optional_file)
        end

        cmd.run options
      rescue Exception => e # rubocop:disable Lint/RescueException
        # .git file was not present
        NorthfieldScripts.logger.err 'tar exploded'
        NorthfieldScripts.logger.err e.message
      end
    end
  end
end
