# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'northfield_scripts/common/berks'

namespace 'berks' do
  desc 'Berks INSTALL'
  task :install do
    TaskLogger.task_block 'Berks INSTALL' do
      options = NorthfieldScripts.settings['berks']['install']['options']
      Berks.install options
    end
  end
end
