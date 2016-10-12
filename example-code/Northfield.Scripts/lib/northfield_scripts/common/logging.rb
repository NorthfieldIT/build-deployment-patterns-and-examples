# encoding: utf-8
require 'logger'

# Central common logging
class Logging
  def initialize(log = STDOUT, output = STDOUT, output_err = STDERR, level = Logger::INFO)
    @output = output
    @output_err = output_err
    @logger = Logger.new log
    @logger.level = level
    @logger.formatter = proc do |severity, datetime, _progname, msg|
      "#{severity[0]} #{datetime.to_datetime.iso8601(6)}: #{msg}\n"
    end
  end

  def trace(str)
    @logger.debug str
  end

  def debug(str)
    @logger.debug str
  end

  def info(str)
    @logger.info str
  end

  def warn(str)
    @logger.warn str
  end

  def error(str)
    @logger.error str
  end

  def fatal(str)
    @logger.fatal str
  end

  def puts(str)
    @output.puts str
  end

  def puts_banner(str)
    puts '****************************************************************'
    puts '*'
    puts "*  #{str}"
    puts '*'
    puts '****************************************************************'
  end

  def err(str)
    @output_err.puts "[ERROR] #{str}"
  end

  def err_banner(str)
    err '****************************************************************'
    err '*                       ERROR'
    err '****************************************************************'
    err '*'
    err "*  #{str}"
    err '*'
    err '****************************************************************'
  end
end
