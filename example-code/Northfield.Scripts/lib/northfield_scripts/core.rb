# encoding: utf-8
require 'northfield_scripts/common/logging'
require 'northfield_scripts/common/settings'

# Holds global access to logger and settings
module NorthfieldScripts
  class << self
    def logger
      @logger ||= Logging.new
    end

    def settings
      @settings ||= Settings.new(config_dirs).compile
    end

    def add_setting_dir(dir)
      config_dirs.push dir
    end

    def core_dir
      Rake.application.original_dir
    end

    private

    def config_dirs
      @dirs ||= []
    end
  end
end

NORTHFIELDSCRIPTS_DIR = File.dirname(File.expand_path(__FILE__))
