# encoding: utf-8
require 'northfield_scripts/common/command'

# Class that contains the rubocop command
class RubocopCommand < Command
  def initialize
    super('rubocop')
  end
end
