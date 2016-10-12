# encoding: utf-8
require 'northfield_scripts/core'

# Related Phabricator functionality
class Phabricator
  def self.log(str)
    if NorthfieldScripts.settings.key?('phabricator')
      phabricator_comment_file = NorthfieldScripts.settings['phabricator']['comment_file']
      phab_file = File.new(phabricator_comment_file, 'a+')
      phab_file.puts(str)
      phab_file.close
    end
  end

  def self.remove
    if NorthfieldScripts.settings.key?('phabricator')
      Phabricator.log 'attempting to delete phab file'
      phabricator_comment_file = NorthfieldScripts.settings['phabricator']['comment_file']
      FileUtils.rm(phabricator_comment_file)
    end
  end
end
