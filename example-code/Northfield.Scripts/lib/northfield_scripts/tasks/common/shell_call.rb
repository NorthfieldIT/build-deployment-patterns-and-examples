# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/generic_runner'

namespace 'common' do
  # shell_call: When you just wanna get a prototype out fast
  rule /^shell_call:/ do |task|
    TaskLogger.task_block task do
      task_def = task.to_s.split(':')
      task_def.shift

      GenericRunner.run_shell_def task_def
    end
  end
end
