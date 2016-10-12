# encoding: utf-8
require 'spec_helper'

describe 'common:preload' do
  # let(:opsscripts_spy) { spy('NorthfieldScripts') }
  let(:opsscripts_spy) { spy('NorthfieldScripts') }
  let(:dir) { './tmp/' }
  let(:phab_file_loc) { './tmp/phab_file' }
  let :run_rake_task do
    Rake::Task['common:preload'].reenable
    Rake.application.invoke_task 'common:preload'
  end

  before do
    stub_const('NorthfieldScripts', opsscripts_spy)
    allow(opsscripts_spy).to receive(:settings).and_return('phabricator' => { 'comment_file' => phab_file_loc })

  end

  it 'will preload the settings by calling for them' do
    run_rake_task

    expect(opsscripts_spy).to have_received(:settings).at_least(:once)
  end
end
