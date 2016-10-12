# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/common/generic_runner'

describe 'generic:cmds:echo' do
  let(:logger_spy) { spy('Logging') }
  let(:generic_runner_spy) { spy('GenericRunner') }
  let(:app_name) { 'app_name' }
  let(:command) { 'echo weee' }
  let(:settings_hash) { { 'app_name' => app_name, 'generic' => { 'cmds' => { 'echo' => command } } } }

  let :run_rake_task do
    Rake::Task['generic:cmds:echo'].reenable
    Rake.application.invoke_task 'generic:cmds:echo'
  end

  before do
    stub_const('GenericRunner', generic_runner_spy)
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will make the shell call' do
    run_rake_task

    expect(generic_runner_spy).to have_received(:run_command).with(command)
  end
end
