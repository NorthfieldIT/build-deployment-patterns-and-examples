# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'northfield_scripts'
  spec.version       = File.exist?('VERSION') ? File.read('VERSION').strip : ''
  spec.authors       = ['Paul Everton']
  spec.email         = ['paul.everton@northfieldit.com']
  spec.description   = %q{Example Script Repo}
  spec.summary       = %q{Northfield Example Script Repo}
  spec.homepage      = 'http://www.northfieldit.com/'

  spec.files         = Dir['lib/**/*'] + %w(README.md LICENSE)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'deep_merge'
  spec.add_dependency 'httpclient'
  spec.add_dependency 'activesupport', '~> 4.0'
  spec.add_dependency 'chefspec', '= 5.1.1'
  spec.add_dependency 'berkshelf', '<= 4.0.1'
  spec.add_dependency 'rubocop', '0.39.0'
  spec.add_dependency 'foodcritic'
  spec.add_dependency 'chef-sugar'
end
