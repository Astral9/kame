require 'kame/utils/tty'

module Kame
  module Logging
    LOGGING_VERBOSITY_LEVELS = {
      debug: 0,
      info: 1,
      warning: 2,
      error: 3,
      quiet: 100
    }
    
    attr_reader :logging_level
    
    def info(s)
      format_and_print(s.to_s) if logging_level_at_least :info
    end
    
    def warning(s)
      format_and_print(s.to_s.yellow) if logging_level_at_least :warning
    end
    
    def error(s)
      format_and_print(s.to_s.red.bold) if logging_level_at_least :error
    end
    
    def debug(s)
      format_and_print(s.to_s.gray) if logging_level_at_least :debug
    end
    
    def self.logging_level=(level)
      unless @@logging_level = LOGGING_VERBOSITY_LEVELS[level.to_sym]
        $stdout.puts "Invalid logging level value: #{level}. Ignoring."
      end
    end
    
    private
    def format_and_print(s)
      puts "[#{Time.now.to_s.gray}] #{s}"
    end
    
    def logging_level_at_least(level)
      !!(not @@logging_level or (@@logging_level and @@logging_level <= LOGGING_VERBOSITY_LEVELS[level]))
    end
  end
end