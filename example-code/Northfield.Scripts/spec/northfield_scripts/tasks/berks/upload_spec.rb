# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/berks/upload'
require 'northfield_scripts/common/berks'

describe 'berks:upload' do
  let(:logger_spy) { spy('Logging') }
  let(:berks_spy) { spy('Berks') }
  let(:cookbook_name) { 'cookbook-name' }
  let(:settings_hash) { { 'app_name' => cookbook_name } }
  let :run_rake_task do
    Rake::Task['berks:upload'].reenable
    Rake.application.invoke_task 'berks:upload'
  end

  before do
    stub_const('Berks', berks_spy)
    settings_hash['berks'] = {}
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will run the task' do
    run_rake_task

    expect(berks_spy).to have_received(:upload).with(cookbook_name)
  end

  context 'app_name contains -chef' do
    it 'will parse it out' do
      cleaned = cookbook_name
      cookbook_name = "#{cookbook_name}-chef"
      run_rake_task

      expect(berks_spy).to have_received(:upload).with(cleaned)
    end
  end

  context 'needs a coookbook name override' do
    it 'will run the task' do
      berks_override = 'blah'

      settings_hash['berks']['cookbook-override'] = berks_override
      run_rake_task

      expect(berks_spy).to have_received(:upload).with(berks_override)
    end
  end
end
