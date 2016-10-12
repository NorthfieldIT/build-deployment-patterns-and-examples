# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/rspec'
require 'northfield_scripts/common/rspec'

describe 'rspec' do
  let(:logger_spy) { spy('Logging') }
  let(:rspec_spy) { spy('Rspec') }
  let(:settings_hash) { { 'berks' => {} } }
  let(:options) { %w('OPTIONS1', 'OPTIONS2') }
  let :run_rake_task do
    Rake::Task['rspec'].reenable
    Rake.application.invoke_task 'rspec'
  end

  before do
    settings_hash['rspec'] = { 'options' => options }
    stub_const('Rspec', rspec_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will run the task' do
    run_rake_task

    expect(rspec_spy).to have_received(:run).with(options)
  end
end
