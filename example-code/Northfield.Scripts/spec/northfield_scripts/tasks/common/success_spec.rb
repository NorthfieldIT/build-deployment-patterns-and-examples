# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/tasks/common/success'
require 'northfield_scripts/core'

describe 'common:success' do
  let(:logger_spy) { spy('Logging') }
  let(:settings_hash) { { 'app_name': 'app-name' } }
  let :run_rake_task do
    Rake::Task['common:success'].reenable
    Rake.application.invoke_task 'common:success'
  end

  before do
    settings_hash['environment'] = 'prd'
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
  end

  it 'will announce a successful deployment' do
    run_rake_task

    expect(logger_spy).to have_received(:puts).with(/ZOIDBERG APPROVES/)
  end
end
