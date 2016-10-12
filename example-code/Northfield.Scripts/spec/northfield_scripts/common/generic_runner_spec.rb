# encoding: utf-8
require 'northfield_scripts/common/generic_runner'
require 'northfield_scripts/common/command'
require 'spec_helper'

describe GenericRunner do
  let(:logger_spy) { spy('Logging') }
  let(:command_spy) { spy('Command') }

  before do
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    stub_const('Command', command_spy)
  end

  describe '.run_shell_def' do
    let(:orig_command) { %w(echo weeeeee) }
    let(:validate_command) { %w(echo weeeeee) }

    it 'will run the command' do
      GenericRunner.run_shell_def orig_command
      expect(command_spy).to have_received(:new).with(validate_command.shift)
      expect(command_spy).to have_received(:run).with(validate_command)
    end
  end

  describe '.run_command' do
    let(:command) { 'command' }
    it 'will run the command' do
      GenericRunner.run_command command
      expect(command_spy).to have_received(:new).with(command)
    end
  end

  describe '.run_command_with_env' do
    context 'without env vars' do
      let(:command) {{
        'command' => 'command1'
      }}


      it 'will run the command' do
        cmd = command['command']
        expect(command_spy).to receive(:new).with(cmd)
        expect(command_spy).to_not receive(:env_var)

        GenericRunner.run_command_with_env command
      end
    end

    context 'with env vars' do
      let(:command) {{
        'command' => 'command1',
        'env_vars' => { 'key1' => 'value1', 'key2' => 'value2'}
      }}



      it 'will run the command' do
        cmd = command['command']
        env_vars = command['env_vars']
        expect(command_spy).to receive(:new).with(cmd)
        env_vars.each do |key, value|
          expect(command_spy).to receive(:env_var).with(key, value)
        end
        GenericRunner.run_command_with_env command
      end
    end
  end
end
