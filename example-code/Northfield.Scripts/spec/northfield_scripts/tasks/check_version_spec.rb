# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/common/phabricator'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/check_version'
require 'northfield_scripts/common/cookbook_info'

describe 'check_version' do
  let(:logger_spy) { spy('Logging') }
  let(:phabricator_spy) { spy('Phabricator') }
  let(:settings_hash) { { 'app_name' => 'some-cookbook-chef', 'phabricator' => { 'comment_file' => phab_file_loc, 'tee_phabricator' => true } } }
  let(:dir) { './tmp/' }
  let(:phab_file_loc) { './tmp/phab_file' }
  let(:chef_return) { 'random-cookbook  0.1.65  0.1.64  0.1.63  0.1.62  0.1.60  0.1.59  0.1.57  0.1.56  0.1.55  0.1.54  0.1.53  0.1.52  0.1.51  0.1.50  0.1.49  0.1.48  0.1.47  0.1.46  0.1.45  0.1.44  0.1.43  0.1.42  0.1.41  0.1.40  0.1.38  0.1.37  0.1.36  0.1.35  0.1.34  0.1.33  0.1.32  0.1.31  0.1.30  0.1.29  0.1.28  0.1.27  0.1.26  0.1.24  0.1.23  0.1.22  0.1.21  0.1.20  0.1.19  0.1.18  0.1.17  0.1.16  0.1.15  0.1.14  0.1.13  0.1.12  0.1.11  0.1.10  0.1.9  0.1.8  0.1.7  0.1.6  0.1.5  0.1.4  0.1.3  0.1.2  0.1.1  0.1.0' }


  let :run_rake_task do
    Rake::Task['check_version'].reenable
    Rake.application.invoke_task 'check_version'
  end

  before do
    settings_hash['berks'] = {}
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
    allow(CookbookInfo).to receive(:server_versions).and_return(chef_return)
    stub_const('Phabricator', phabricator_spy)
  end

  context 'when cookbook has been properly bumped' do
    it 'will output success' do
      version = '1.2.3'
      message = "The version #{version} has not yet been uploaded. You're G2G!"
      allow(CookbookInfo).to receive(:local_version).and_return(version)
      run_rake_task
      expect(logger_spy).to have_received(:puts).with(message)
      expect(phabricator_spy).to have_received(:log).with(message)
      expect(phabricator_spy).not_to have_received(:remove)
    end
  end

  context 'when cookbook has not been properly bumped' do
    it 'will output a suggested bump' do
      version = '0.1.65'
      message = "The version #{version} has already been uploaded. Did you want to give it a bump??"
      allow(CookbookInfo).to receive(:local_version).and_return(version)
      run_rake_task
      expect(logger_spy).to have_received(:err_banner).with(message)
      expect(phabricator_spy).to have_received(:log).with(message)
      expect(phabricator_spy).not_to have_received(:remove)
    end
  end
end
