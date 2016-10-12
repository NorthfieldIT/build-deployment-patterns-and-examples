# encoding: utf-8
require 'northfield_scripts/common/tasklogger'

namespace 'common' do
  desc 'Pre-load the settings for output'
  task :preload do
    NorthfieldScripts.settings
  end
end
