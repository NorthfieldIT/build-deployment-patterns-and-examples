# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/rubocop'

desc 'Rubocop runner'
task :rubocop do
  TaskLogger.task_block 'Rubocop Runner' do
    Rubocop.run
  end
end
