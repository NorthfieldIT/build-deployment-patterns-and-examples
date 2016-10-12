# encoding: utf-8
require 'northfield_scripts/common/tasklogger'
require 'spec_helper'

# rubocop:disable Metrics/LineLength
describe TaskLogger do
  let(:logger_spy) { spy('Logging') }
  let(:buildsystem_spy) { spy('BuildSystem') }
  before do
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return('verbose' => true)
    stub_const('BuildSystem', buildsystem_spy)
    allow(buildsystem_spy).to receive(:running_from).and_return(false)
  end

  describe '.task_block' do
    context 'with a passing code block' do
      it 'will run a block of code' do
        has_ran = false
        TaskLogger.task_block 'test' do
          has_ran = true
        end

        expect(has_ran).to be true
      end
      it 'will log start' do
        task_name = 'some task'

        has_ran = false
        TaskLogger.task_block task_name do
          has_ran = true
        end

        expect(logger_spy).to have_received(:puts).with("* START #{task_name}")
      end

      it 'will log end' do
        task_name = 'some task'

        has_ran = false
        TaskLogger.task_block task_name do
          has_ran = true
        end

        expect(logger_spy).to have_received(:puts).with("* END #{task_name}")
      end
      it 'will output verbose' do
        task_name = 'some task'

        has_ran = false
        TaskLogger.task_block task_name do
          has_ran = true
        end

        expect(logger_spy).to have_received(:puts).with("* END #{task_name}")
      end
    end

    context 'with verbose setting output off' do

      before do
        allow(NorthfieldScripts).to receive(:settings).and_return('verbose' => false)
      end
      it 'won\'t output the configs to screen by default' do

        task_name = 'some task'

        has_ran = false
        TaskLogger.task_block task_name do
          has_ran = true
        end
        expect(logger_spy).not_to have_received(:puts).with("* END #{task_name}")
      end
    end

    context 'with a failing code block' do
      let(:phab_spy) { spy('Phabricator') }

      before do
        stub_const('Phabricator', phab_spy)
      end
      it 'will raise error' do
        expect{ # rubocop:disable Style/BlockDelimiters
          TaskLogger.task_block 'test' do
            1 / 0
          end
        }.to raise_error ZeroDivisionError
      end
      it 'will log to phabricator' do
        begin
          TaskLogger.task_block 'test' do
              1 / 0
          end
        rescue ZeroDivisionError # rubocop:disable Lint/HandleExceptions
        end
        expect(phab_spy).to have_received(:log).at_least(2).times
        expect(phab_spy).to have_received(:log).with('test has failed. Please check the console output from Jenkins if the below output is not enough.')
      end
    end
  end

end
