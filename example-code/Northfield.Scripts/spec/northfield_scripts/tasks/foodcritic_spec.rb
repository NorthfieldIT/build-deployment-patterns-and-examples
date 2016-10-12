# encoding: utf-8
require 'spec_helper'
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'northfield_scripts/tasks/rspec'
require 'northfield_scripts/common/rspec'
require 'foodcritic'

describe 'rspec' do
  let(:logger_spy) { spy('Logging') }
  let(:context_spy) { spy('FoodCritic::ContextOutput') }
  let(:linter_spy) { spy('FoodCritic::Linter') }
  let(:review_spy) { spy('FoodCritic::Review') }
  let(:warning_spy) { spy('FoodCritic::Warning') }
  let(:settings_hash) { { 'foodcritic' => {} } }
  let(:max_warnings) { 0 }
  let :run_rake_task do
    Rake::Task['foodcritic'].reenable
    Rake.application.invoke_task 'foodcritic'
  end

  before do
    settings_hash['foodcritic'] = { 'max_warnings' => 0 }
    allow(NorthfieldScripts).to receive(:logger).and_return(logger_spy)
    allow(NorthfieldScripts).to receive(:settings).and_return(settings_hash)
    allow(FoodCritic::ContextOutput).to receive(:new).and_return(context_spy)
    allow(FoodCritic::Linter).to receive(:new).and_return(linter_spy)

    allow(context_spy).to receive(:output)
    allow(linter_spy).to receive(:check).and_return(review_spy)
  end

  context 'with warnings less than the max' do
    before do
      allow(review_spy).to receive(:warnings).and_return([])
      allow(review_spy).to receive(:failed?).and_return(false)
    end

    it 'will run the task' do
      run_rake_task
    end
  end


  context 'with warnings more than the max' do
    let(:warnings) { %w(first second) }
    before do
      allow(review_spy).to receive(:warnings).and_return(warnings)
      allow(review_spy).to receive(:failed?).and_return(false)
    end

    it 'will raise an error' do

      expect{ # rubocop:disable Style/BlockDelimiters
        run_rake_task
      }.to raise_error "There are #{warnings.count} warnings. The maximum is #{max_warnings}."
    end
  end

  context 'with failures' do
    before do
      allow(review_spy).to receive(:warnings).and_return([])
      allow(review_spy).to receive(:failed?).and_return(true)
    end

    it 'will raise an error' do

      expect{ # rubocop:disable Style/BlockDelimiters
        run_rake_task
      }.to raise_error 'There are Foodcritic failures'
    end
  end
end
