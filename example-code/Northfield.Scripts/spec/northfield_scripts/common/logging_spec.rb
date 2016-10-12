# encoding: utf-8
require 'northfield_scripts/common/logging'
require 'northfield_scripts/core'
require 'logger'
require 'spec_helper'

describe Logging do
  let(:logger) { Logging.new(@log, @stdout, @stderror, Logger::DEBUG) }
  before do
    @log = StringIO.new
    @stdout = StringIO.new
    @stderror = StringIO.new
  end

  describe '#put' do
    it 'will log to stdout with annotation' do
      log_message = 'LOG MESSAGE'
      logger.puts log_message

      @stdout.rewind

      expect(@stdout.read).to eq("#{log_message}\n")
    end
  end

  describe '#err' do
    it 'will log to stdout with annotation' do
      log_message = 'LOG MESSAGE'
      logger.err log_message

      @stderror.rewind
      expect(@stderror.read).to eq("[ERROR] #{log_message}\n")
    end
  end

  describe '#race' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.trace log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end

  describe '#debug' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.debug log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end

  describe '#info' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.info log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end

  describe '#warn' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.warn log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end

  describe '#error' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.error log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end

  describe '#fatal' do
    it 'will send to log' do
      log_message = 'LOG MESSAGE'
      logger.fatal log_message

      @log.rewind
      expect(@log.read).to include(log_message)
    end
  end
end
