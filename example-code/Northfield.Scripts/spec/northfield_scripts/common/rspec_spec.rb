# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/rspec'

describe Rspec do
  let(:rspec_cmd_spy) { spy('RspecCommand') }

  before do
    stub_const('RspecCommand', rspec_cmd_spy)
  end

  describe '.run' do
    it 'will call Rspec' do
      Rspec.run []

      expect(rspec_cmd_spy).to have_received(:run)
    end

    it 'will call RSpec with args' do
      args = %w('arg1', 'arg2')

      Rspec.run args

      expect(rspec_cmd_spy).to have_received(:run).with(args)
    end
  end
end
