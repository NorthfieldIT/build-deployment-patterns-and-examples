# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/berks/install'
require 'northfield_scripts/common/berks'

describe 'berks:install' do
  let(:logger_spy) { spy('Logging') }
  let(:berks_spy) { spy('Berks') }
  let(:settings_hash) { { 'berks' => {} } }
  let(:options) { %w('OPTIONS1', 'OPTIONS2') }
  let :run_rake_task do
    Rake::Task['berks:install'].reenable
    Rake.application.invoke_task 'berks:install'
  end

  before do
    settings_hash['berks']['install'] = { 'options' => options }
    stub_const('Berks', berks_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will run the task' do
    run_rake_task

    expect(berks_spy).to have_received(:install).with(options)
  end
end
