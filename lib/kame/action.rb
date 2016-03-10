require 'kame/utils/functional'
require 'kame/utils/logging'

module Kame
  
  class Action
    include Kame::Functional
    include Kame::Logging
    
    attr_accessor :next_action, :link
    attr_reader :config_delegate
    
    def initialize(*args)
      @args = args
      
      @last_action = self
    end
    
    # and then
    def &(next_action)
      append_action next_action, :hard
    end
    
    # or then
    def |(next_action)
      append_action next_action, :soft
    end
    
    def config_delegate=(delegate)
      @config_delegate = delegate
      @next_action.config_delegate = delegate if next_action
    end
        
    def dry_run
      @args.join ' '
    end
    
    def prog
      @args.first
    end
    
    def run!
      info dry_run
      
      this = system dry_run
      exitstat = $?.exitstatus
      if @link == :soft
        warning "Previous command returned #{exitstat}, but ignoring (soft link)." if exitstat != 0
        return @next_action.run!
      elsif @link == :hard and this
        return @next_action.run!
      elsif not this
        error "Command \"#{prog}\" exited abnormaly: #{exitstat}."
      end
      
      this
    end
    
    private 
    def append_action(action, link)
      @last_action.next_action = action
      @last_action.link = link
      
      @last_action = @last_action.next_action
      
      self
    end
  end
  
  # TODO: think of a better name
  class FooAction < Action
    def initialize(prog, default, *args)
      @prog_stub = (prog.is_a? Symbol) ? prog : :"#{prog}"
      @default_prog = default
      
      super args
    end
    
    def dry_run
      ([prog]+@args).join ' '
    end
    
    def prog 
      if @config_delegate and (c = get @prog_stub)
        return c
      end
      
      @default_prog
    end
  end
  
end