$: << './'

require 'northfield_scripts/tasks'

task :northfield_build => [
  :northfield_build_init_seam,
  'rubocop',
  'rspec',
  :northfield_build_end_seam
]
