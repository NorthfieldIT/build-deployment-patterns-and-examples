# encoding: utf-8
require 'northfield_scripts/core'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/common/tasklogger'
require 'spec_helper'

describe Settings do
  let(:logger_spy) { spy('Logging') }
  let(:settings) { Settings.new }

  before do
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
  end
  describe '#load' do
    it 'will load default configs' do
      configs = settings.compile

      expect(configs['rubocop']['max_offenses']).to eq(0)
    end
  end
end
