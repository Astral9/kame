require 'kame/action'
require 'kame/target'

module Kame
  class Core
    include Kame::Config
    
    def initialize
      @targets = {}
    end
    
    def target(name)
      @targets[name] ||= Target.new
      
      if block_given?
        yield @targets[name]
      end
    end
    
    def debug
      @targets
    end
  end
  
  module Delegator
    class << self
      @@target = Core.new
      
      def register(*methods)
        methods.each do |f|
          define_method(f) { |*args, &block| @@target.send f, *args, &block }
        end  
      end
    end
    
    register :target, :set, :get, :debug
  end
  
end