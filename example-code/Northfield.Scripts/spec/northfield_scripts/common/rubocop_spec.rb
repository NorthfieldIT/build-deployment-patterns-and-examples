# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/rubocop'

describe Rubocop do
  let(:rubocop_cmd_spy) { spy('RubocopCommand') }
  let(:logger_spy) { spy('Logging') }
  let(:phabricator_spy) { spy('Phabricator') }
  let(:settings_hash) { { 'app_name': 'app-name' } }
  let(:rubocop_file) { './rubocop.html' }
  let(:max_errors) { 20 }

  before do
    stub_const('RubocopCommand', rubocop_cmd_spy)
    stub_const('Phabricator', phabricator_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)


    settings_hash['rubocop'] = {}


    FileUtils.rm(rubocop_file) if File.exist?(rubocop_file)
    default_file = File.new(rubocop_file, 'w+')
    default_file.puts("#{max_errors} offenses detected")
    default_file.close
  end

  describe '.run' do
    it 'will fail when surpased max offenses' do
      max_offenses = 0
      settings_hash['rubocop']['max_offenses'] = max_offenses

      expect { Rubocop.run }.to raise_error('Rubocop has failed.')
      expect(logger_spy).to have_received(:err).with("There are #{max_errors} offenses. The max is #{max_offenses}. Please view rubocop.html")
    end

    it 'will succeed when under max' do
      settings_hash['rubocop']['max_offenses'] = max_errors + 1

      Rubocop.run

      expect(rubocop_cmd_spy).to have_received(:run).twice
    end
  end
end
