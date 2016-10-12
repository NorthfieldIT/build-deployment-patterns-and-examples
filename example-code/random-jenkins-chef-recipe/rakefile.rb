$: << './'

require 'northfield_scripts/tasks'


task :northfield_build => [
  :northfield_build_init_seam,
  'berks:install',
  'rubocop',
  'foodcritic',
  'rspec',
  'check_version',
  :northfield_build_end_seam
]

task northfield_deploy: [
  :northfield_deploy_init_seam,
  'berks:install',
  'berks:upload',
  :northfield_deploy_end_seam
]