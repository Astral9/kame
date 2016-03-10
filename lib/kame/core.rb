require 'kame/action'
require 'kame/target'

require 'kame/utils/logging'

require 'optparse'

module Kame
  class Core
    include Kame::Config
    include Kame::Logging
    
    def initialize
      @targets = {}
    end
    
    def target(name)
      @targets[name] ||= Target.new
      
      if block_given?
        yield @targets[name]
      end
    end
    
    def build(target_name, rule_name)
      Kame::Logging.logging_level = get :logging_level if get :logging_level
      
      begin
        result = build_raise(target_name, rule_name)
        
        if result
          puts "Build complete."
        else
          $stderr.puts "Build failed."
          abort
        end
      rescue RuntimeError => e
        error e.message
        
        $stderr.puts "Build failed."
        abort
      end
    end
    
    private
    def build_raise(target_name, rule_name)
      target_name = get :default_target unless target_name
      raise "No target selected. Abort." unless target_name
      
      target = @targets[target_name]
      raise "Invalid target \"#{target_name}\". Abort." unless target
      
      target.exec rule_name
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
    
    register :set, :get, :target
    
    at_exit do
      search_files = [ 'Kamefile', 'kamefile' ]
      
      options = {}
      
      OptionParser.new do |opts|
        opts.banner = "Usage: kame [options] [TARGET:]RULE"
        
        opts.on '-f FILENAME', 'Specify which file to be used as the Kamefile.' do |filename|
          options[:file] = filename
        end
        
        opts.on '-n NUM_THREADS', 'Running N child processes in parallel.' do |n|
          options[:nthreads] = n.to_i
        end
        
        opts.on '-v LEVEL', 'Override the verbosity level.' do |level|
          options[:logging_level] = level
        end
        
        opts.on_tail '-h', '--help', 'Display this help message.' do
          puts opts
          exit
        end
      end.parse! ARGV
      
      if options[:file]
        load options[:file]
      else
        search_files.each do |f|
          begin 
            load f
            break
          rescue LoadError
          end
        end
      end
      
      rule = ARGV.size == 0 ? 'all' : ARGV.first
      
      if rule.include? ':'
        target, rule = rule.split ':'
        target = target.to_sym
      else
        target = nil
      end
      
      @@target.set :logging_level, options[:logging_level] if options[:logging_level]
      @@target.build target, rule
    end
  end
  
end