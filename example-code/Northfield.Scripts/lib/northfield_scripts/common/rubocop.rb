# encoding: utf-8
require 'northfield_scripts/common/commands/rubocop_command'

# Interface for Rubocop
class Rubocop
  def self.run
    begin
      cmd = RubocopCommand.new
      cmd.run {}
    rescue Exception => e # rubocop:disable Lint/RescueException
      NorthfieldScripts.logger.puts 'rubocop returned a non-zero return'
    end
    begin
      cmd = RubocopCommand.new
      cmd.run NorthfieldScripts.settings['rubocop']['options']
    rescue Exception => e # rubocop:disable Lint/RescueException
      NorthfieldScripts.logger.puts 'rubocop returned a non-zero return'
    end

    output = ''
    open('./rubocop.html') { |f| output = f.grep(/[0-9]* offense[s]* detected/).first.sub! ' offenses detected', '' }

    max_offenses = NorthfieldScripts.settings['rubocop']['max_offenses']
    cur_offenses = output.to_i
    NorthfieldScripts.logger.puts "There are #{cur_offenses} offenses. The max is #{max_offenses}."

    if cur_offenses > max_offenses
      NorthfieldScripts.logger.err 'Rubocop has failed.'
      NorthfieldScripts.logger.err "There are #{cur_offenses} offenses. The max is #{max_offenses}. Please view rubocop.html"
      raise 'Rubocop has failed.'
    end
  end
end
