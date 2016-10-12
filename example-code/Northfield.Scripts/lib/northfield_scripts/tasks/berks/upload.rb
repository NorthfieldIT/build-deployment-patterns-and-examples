# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/berks'

namespace 'berks' do
  desc 'Berks UPLOAD a cookbook'
  task :upload do
    TaskLogger.task_block 'Berks UPLOAD a cookbook' do
      cookbook_name = NorthfieldScripts.settings['app_name']
      cleaned_cookbook_name = cookbook_name.gsub('-chef', '')
      cleaned_cookbook_name = NorthfieldScripts.settings['berks']['cookbook-override'] if NorthfieldScripts.settings['berks'].key?('cookbook-override')
      Berks.upload cleaned_cookbook_name
    end
  end
end
