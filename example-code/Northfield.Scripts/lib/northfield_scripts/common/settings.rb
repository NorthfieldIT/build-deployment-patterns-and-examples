# encoding: utf-8
require 'yaml'
require 'deep_merge'
require 'deep_merge/rails_compat'
require 'json'
require 'northfield_scripts/core'

# Class for collecting settings from YAML configs
class Settings
  def initialize(dirs = [])
    @logger = NorthfieldScripts.logger
    @dirs = dirs
  end

  def add_dir(search_dir)
    @dirs.push search_dir
  end

  def compile
    config_settings = get_settings(get_base_yaml_file('configs'))
    files_found = []

    @dirs.each do |x|
      file = "#{x}configs.yml"
      files_found << file
      additional_settings_default = get_settings(file)
      config_settings = merge_settings(config_settings, additional_settings_default)
    end

    config_settings['verbose'] = ENV['verbose'] if ENV['verbose']

    if config_settings['verbose']
      files_found.each do |x|
        @logger.puts "Getting Settings from #{x}"
      end
    end

    if config_settings['verbose']
      @logger.puts ''
      @logger.puts '--- SETTINGS (START) ---'
      @logger.puts ''
      @logger.puts JSON.pretty_generate(config_settings)
      @logger.puts ''
      @logger.puts '--- SETTINGS (END) ---'
      @logger.puts ''
    end

    config_settings
  end

  def get_settings(file)
    config_settings = {}
    config_settings = YAML.load_file(file) if File.exist?(file)

    config_settings = {} unless config_settings
    config_settings
  end

  def get_local_yaml_file(file_name)
    "./buildscripts/configs/#{file_name}.yml"
  end

  def get_base_yaml_file(file_name)
    File.join(NORTHFIELDSCRIPTS_DIR, 'configs', "#{file_name}.yml")
  end

  def merge_settings(settings, additional_settings)
    settings.deeper_merge!(additional_settings, unpack_arrays: ',')
  end
end
