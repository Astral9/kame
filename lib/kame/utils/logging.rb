require 'kame/utils/tty'

module Kame
  module Logging
    def info(s)
      format_and_print(s)
    end
    
    def warning(s)
      format_and_print(s.yellow)
    end
    
    def error(s)
      format_and_print(s.red.bold)
    end
    
    def debug(s)
      format_and_print(s.gray)
    end
    
    private
    def format_and_print(s)
      puts "[#{Time.now.to_s.gray}] #{s}"
    end
  end
end