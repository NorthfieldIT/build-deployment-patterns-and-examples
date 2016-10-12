# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/berks'

describe Berks do
  let(:berks_cmd_spy) { spy('BerksCommand') }

  before do
    stub_const('BerksCommand', berks_cmd_spy)
  end

  describe '.install' do
    it 'will call BerksCommand with install' do
      Berks.install []

      expect(berks_cmd_spy).to have_received(:arg).with('install')
    end

    it 'will call BerksCommand with args' do
      args = %w('arg1', 'arg2')

      Berks.install args

      expect(berks_cmd_spy).to have_received(:run).with(args)
    end
  end

  describe '.upload' do
    let(:cookbook_name) { 'some_cookbook' }
    let(:io_spy) { spy('IO') }
    let(:logger_spy) { spy('Logging') }
    before do
      stub_const('IO', io_spy)
      allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    end

    context 'a cookbook with a proper bump' do
      before do
        allow(io_spy).to receive(:popen).with("berks upload #{cookbook_name}").and_return(io_spy)
        allow(io_spy).to receive(:gets).and_return("Uploaded #{cookbook_name} (0.1.19) to: 'some chef server'", nil)
      end
      it 'will upload the cookbook' do
        Berks.upload cookbook_name
      end
    end

    context 'a cookbook that has not been bumped' do
      before do
        allow(io_spy).to receive(:popen).with("berks upload #{cookbook_name}").and_return(io_spy)
        allow(io_spy).to receive(:gets).and_return("Skipping #{cookbook_name} (0.1.19) (frozen)", nil)
      end
      it 'will raise an error' do
        expect{ # rubocop:disable Style/BlockDelimiters
          Berks.upload cookbook_name
        }.to raise_error
      end
    end
  end
end
