# encoding: utf-8
require 'northfield_scripts/common/commands/berks_command'
require 'northfield_scripts/core'

# Interface for Berks
class CookbookInfo
  def self.local_version
    `cat metadata.rb | grep version`.scan(/([0-9.]{4,})/).last.first
  end

  def self.server_versions(cookbook)
    `knife cookbook show #{cookbook}`
  end
end
