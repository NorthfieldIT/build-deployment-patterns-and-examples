# encoding: utf-8
require 'northfield_scripts/core'
require 'northfield_scripts/common/phabricator'

# Interface for marking start and end of a task
class TaskLogger
  def self.task_block(message, delete_phab = true, &code)
    logger = NorthfieldScripts.logger

    # force a setting load
    NorthfieldScripts.settings

    start_time = Time.now
    start_time_formatted = start_time.strftime('%H:%M:%S')

    logger.puts '*********************************************************'
    logger.puts "* START #{message}"
    logger.puts '*********************************************************'
    if NorthfieldScripts.settings['verbose']
      logger.puts '*'
      logger.puts "* Started @ #{start_time_formatted}"
      logger.puts '*'
      logger.puts '*********************************************************'
    end

    begin
      code.call
    rescue Exception => e # rubocop:disable Lint/RescueException
      Phabricator.log "#{message} has failed. Please check the console output from Jenkins if the below output is not enough."
      Phabricator.log e
      logger.err e
      raise e
    end

    Phabricator.remove if delete_phab
    end_time = Time.now
    total_duration = (end_time - start_time)
    duration_mins = (total_duration / 60).round(0)
    duration_seconds = (total_duration - duration_mins * 60).round(0)
    end_time_formatted = start_time.strftime('%H:%M:%S')
    if NorthfieldScripts.settings['verbose']
      logger.puts '*********************************************************'
      logger.puts "* END #{message}"
      logger.puts '*********************************************************'
      logger.puts '*'
      logger.puts "* Ended @ #{end_time_formatted} => lasted #{duration_mins} minutes and #{duration_seconds} seconds"
      logger.puts '*'
      logger.puts '*********************************************************'
      logger.puts ''
      logger.puts ''
      logger.puts ''
      logger.puts ''
      logger.puts ''
    end
  end
end
