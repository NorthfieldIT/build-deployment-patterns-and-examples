# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/rspec'

desc 'RSpec runner'
task :rspec do
  TaskLogger.task_block 'RSpec Runner' do
    options = NorthfieldScripts.settings['rspec']['options']
    Rspec.run options
  end
end
