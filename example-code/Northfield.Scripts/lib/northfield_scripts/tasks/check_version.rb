# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/common/phabricator'
require 'northfield_scripts/core'
require 'northfield_scripts/common/cookbook_info'

task :check_version do
  TaskLogger.task_block 'Version Checkers', false do
    versions = CookbookInfo.server_versions NorthfieldScripts.settings['app_name']
    metadata_version = CookbookInfo.local_version

    NorthfieldScripts.logger.puts "The local version is #{metadata_version}"
    NorthfieldScripts.logger.puts "The server versions are #{versions}"

    if versions.include? metadata_version
      message = "The version #{metadata_version} has already been uploaded. Did you want to give it a bump??"
      NorthfieldScripts.logger.err_banner message
    else
      message = "The version #{metadata_version} has not yet been uploaded. You're G2G!"
      NorthfieldScripts.logger.puts message
    end
    Phabricator.log message
  end
end
