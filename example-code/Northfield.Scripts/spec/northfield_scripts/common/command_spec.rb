# encoding: utf-8
require 'northfield_scripts/core'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/common/command'
require 'spec_helper'

describe Command do
  let(:dir) { './tmp/' }
  let(:phab_file_loc) { './tmp/phab_file' }
  let(:logger_spy) { spy('Logging') }
  let(:command_name) { 'echo' }
  let(:command) { Command.new(command_name) }

  before do
    Dir.mkdir(dir) unless File.exist? dir
    allow(NorthfieldScripts).to receive(:settings).and_return('phabricator' => { 'comment_file' => phab_file_loc, 'tee_phabricator' => true })
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    FileUtils.rm(phab_file_loc) if File.exist?(phab_file_loc)
  end

  describe '#run' do
    context 'with a successful command' do
      it 'will run a command' do
        command.run ['running']
      end

      it 'will add command output to phab file' do
        command.run ['running']

        phab_file = File.new(phab_file_loc, 'r')
        phab_contents = phab_file.read
        phab_file.close

        expect(phab_contents).to include('running')
      end
    end
    context 'with a successful command with tee turned off' do
      it 'will run a command' do
        new_command = Command.new('echo', false)
        new_command.run ['running']
      end

      it 'will add command output to phab file' do
        new_command = Command.new('echo', false)
        new_command.run ['running']

        expect(File).not_to exist(phab_file_loc)
      end
    end
  end
end
