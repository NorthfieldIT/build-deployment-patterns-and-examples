# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'northfield_scripts/core'
require 'foodcritic'

# ripped from https://github.com/acrmp/foodcritic/blob/master/lib/foodcritic/rake_task.rb
task :foodcritic do
  TaskLogger.task_block 'Foodcritic Runner' do
    default_options = {
      fail_tags: ['correctness'], # differs to default cmd-line behaviour
      tags: %w(~FC064 ~FC065),
      cookbook_paths:  [Dir.pwd],
      exclude_paths: [%w(test/**/* spec/**/* features/**/*)],
      context: false,
      chef_version: FoodCritic::Linter::DEFAULT_CHEF_VERSION
    }

    result = FoodCritic::Linter.new.check(default_options)
    printer = FoodCritic::ContextOutput.new
    printer.output(result) if result.warnings.any?

    cur_warnings = result.warnings.count
    max_warnings = NorthfieldScripts.settings['foodcritic']['max_warnings']

    NorthfieldScripts.logger.puts "There are #{cur_warnings} warnings."
    raise "There are #{cur_warnings} warnings. The maximum is #{max_warnings}." if cur_warnings > max_warnings

    NorthfieldScripts.logger.err 'These are the Foodcritic Failures' if result.failed?
    NorthfieldScripts.logger.err '*********************************' if result.failed?
    result.failures.each do |failure|
      NorthfieldScripts.logger.err "#{failure.rule.code} - #{failure.rule.name}"
    end
    NorthfieldScripts.logger.err '*********************************' if result.failed?

    raise 'There are Foodcritic failures' if result.failed?
  end
end
