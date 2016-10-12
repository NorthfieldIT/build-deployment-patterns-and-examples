# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/rubocop'
require 'northfield_scripts/common/rubocop'

describe 'rubocoped' do
  let(:logger_spy) { spy('Logging') }
  let(:settings_hash) { { 'rubocop' => {} } }
  let(:rubocop_spy) { spy('Rubocop') }
  let :run_rake_task do
    Rake::Task['rubocop'].reenable
    Rake.application.invoke_task 'rubocop'
  end

  before do
    settings_hash['rubocop'] = { 'options' => '' }
    stub_const('Rubocop', rubocop_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will run the task' do
    run_rake_task

    expect(rubocop_spy).to have_received(:run)
  end
end
