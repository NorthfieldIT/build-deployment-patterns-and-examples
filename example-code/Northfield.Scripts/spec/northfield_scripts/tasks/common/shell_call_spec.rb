# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/common/generic_runner'

describe 'shell_call:echo:weeee' do
  let(:logger_spy) { spy('Logging') }
  let(:generic_runner_spy) { spy('GenericRunner') }
  let(:app_name) { 'app_name' }
  let(:settings_hash) { { 'app_name' => app_name, 'shell_call' => { 'nfit_slack_channel' => 'blah' } } }

  let :run_rake_task do
    Rake::Task['shell_call:echo:weeee'].reenable
    Rake.application.invoke_task 'shell_call:echo:weeee'
  end

  before do
    stub_const('GenericRunner', generic_runner_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will make the shell call' do
    run_rake_task

    expect(generic_runner_spy).to have_received(:run_shell_def).at_least(:once)
  end
end
