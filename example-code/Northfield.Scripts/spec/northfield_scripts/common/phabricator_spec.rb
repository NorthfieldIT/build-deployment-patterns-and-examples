# encoding: utf-8
require 'rspec'
require 'northfield_scripts/common/phabricator'
require 'spec_helper'

describe Phabricator do
  describe '.log' do
    let(:dir) { './tmp/' }
    let(:phab_file_loc) { './tmp/phab_file' }

    before do
      Dir.mkdir(dir) unless File.exist? dir
      allow(NorthfieldScripts).to receive(:settings).and_return('phabricator' => { 'comment_file' => phab_file_loc, 'tee_phabricator' => true } )

      FileUtils.rm(phab_file_loc) if File.exist?(phab_file_loc)
    end

    it 'will add text to phabricator comment file' do
      output = 'LOLOLOLOL'

      Phabricator.log output

      phab_file = File.new(phab_file_loc, 'r')
      phab_contents = phab_file.read
      phab_file.close

      expect(phab_contents).to include(output)
    end
  end
  describe '.remove' do
    let(:dir) { './tmp/' }
    let(:phab_file_loc) { './tmp/phab_file' }

    before do
      Dir.mkdir(dir) unless File.exist? dir
      allow(NorthfieldScripts).to receive(:settings).and_return('phabricator' => { 'comment_file' => phab_file_loc, 'tee_phabricator' => true })

      FileUtils.rm(phab_file_loc) if File.exist?(phab_file_loc)
    end

    it 'will remove comment file' do
      output = 'LOLOLOLOL'

      Phabricator.log output
      Phabricator.remove

      file_exists = File.exist?(phab_file_loc)
      expect(file_exists).to eq(false)
    end
  end
end
