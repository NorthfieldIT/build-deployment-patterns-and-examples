# encoding: utf-8
require 'northfield_scripts/tasks/common/package'
require 'northfield_scripts/tasks/common/preload'
require 'northfield_scripts/tasks/common/success'
require 'northfield_scripts/tasks/common/generic'
require 'northfield_scripts/tasks/common/shell_call'
require 'northfield_scripts/tasks/berks/install'
require 'northfield_scripts/tasks/berks/upload'
require 'northfield_scripts/tasks/rspec'
require 'northfield_scripts/tasks/rubocop'
require 'northfield_scripts/tasks/foodcritic'
require 'northfield_scripts/tasks/check_version'
desc 'Empty Task to dump configuration variables'
task dump: ['common:preload']

task northfield_build_init_seam: [
  'common:preload',
  'generic:cmds:echo_hello',
  'generic:cmds_with_env:echo_wee',
  'shell_call:ls:-la'
]

task northfield_build_end_seam: [
  'common:package'
]


task northfield_deploy_init_seam: [
  'common:preload'
]

task northfield_deploy_end_seam: [
  'common:success'
]


NorthfieldScripts.add_setting_dir(Dir.pwd + '/buildscripts/configs/')
