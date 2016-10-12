# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/generic_runner'

namespace 'common' do
  rule /^generic:/ do |task|
    TaskLogger.task_block task do
      task_type_loc = 1
      task_name_loc = 2
      task_types = %w(cmds cmds_with_env)
      task_string = task.to_s
      task_def = task_string.split(':')
      task_name = task_def[task_name_loc]
      task_type = task_def[task_type_loc]

      if task_types.include?(task_type)
        command = NorthfieldScripts.settings['generic'][task_type][task_name]

        if task_type == 'cmds'
          GenericRunner.run_command command
        else
          GenericRunner.run_command_with_env command
        end
      else
        NorthfieldScripts.logger.err "#{task_types} is not a task type. Options are #{task_types}"
        raise "#{task_types} is not a task type."
      end
    end
  end
end
