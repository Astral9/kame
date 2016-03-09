require 'kame/utils/config'
require 'kame/utils/logging'
require 'kame/utils/functional'

require 'singleton'
require 'set'

module Kame
  class Target
    include Kame::Config
    include Kame::Logging
    include Kame::Functional
    
    def initialize
      @rules = []
    end
    
    def rule(pat, options = {}, &block)
      raise "No action for rule \"#{pat}\"." unless block_given?
      
      @rules << Rule.new(pat, options, block)
    end
    
    def exec(s)
      void(exec_rec s, Set.new, [])
    end
  
    # TODO: use graph -> support parallelism
    def exec_rec(s, built, building)
      debug "Building #{s}."
      
      rule = find_rule s
      raise "No rule for making \"#{s}\". Stop." unless rule
      # end if the rule doesn't need to be built
      debug "But #{s} is a file." if rule.file?
      return unless rule.needs_update?(s)
      
      matches = rule.match(s)[1..-1]
      
      building << s
      
      filled_deps = []
      rule.deps.each do |dep|
        dep = dep.dup
        matches.each { |m| dep.sub!(/%/, m) }
        filled_deps << dep
        
        if built.include? dep
          info "Dependency #{s} -> #{dep} already built. Skipping."
        elsif building.include? dep
          warning "Cyclic dependency found: #{s} -> #{dep}. Ignoring."
        else
          exec_rec dep, built, building
        end
      end
      
      building.pop
      info "Building #{s}: "
      rule.exec_rule s, filled_deps
      
      built << s
    end
    
    def find_rule(s)
      # there is such rule
      @rules.find { |r| r.match? s } ||
      # or there is such file 
      StubRule.get(s)
    end
    
    private :exec_rec, :find_rule
  end
  
  module RuleMode
    RECURSIVE     = 1
    FORCE_REBUILD = 1 << 1
  end
  
  class Rule
    include Kame::Logging
    
    # support for make-like pattern matchings
    MAKE_REPLACE_REGEX      = /(%)|(\.)/
    MAKE_REPLACE_REGEX_DICT = { '%' => '(.+)', '.' => '\.' }
    
    def self.build_regex(pattern)
      /^#{pattern.to_s.gsub MAKE_REPLACE_REGEX, MAKE_REPLACE_REGEX_DICT}$/
    end
    
    def initialize(pattern, options, action_proc)
      @regex = Rule.build_regex pattern
      
      @options = {
        deps: [],
        mode: 0
      }.merge options
      populate_options!
      
      @action_proc = action_proc
    end
    
    def populate_options!
      @options.each do |k, _|
        instance_eval <<-EVAL
          def #{k}
            @options[:"#{k}"]
          end
        EVAL
      end
    end
    
    def needs_update?(s)
      return true if RuleMode::FORCE_REBUILD
      
      # TODO: rewrite stub
      true
    end
    
    def match?(s)
      @regex.match s
    end
    alias match match?
    
    def exec_rule(s, filled_deps)
      matches = match? s
      raise "The rule does not match the name." unless matches
      
      matches = matches.to_a[1..-1]
      name = s[0...-File.extname(s).length]
      
      error "pretending to be executing action for #{s}, and received args #{filled_deps}"
      # @action_proc[name, *matches].run!
    end
    
    def file?
      false
    end
  end
  
  class StubRule < Rule
    include Singleton
    
    def initialize
    end
    
    def needs_update?(_)
      false
    end
    
    def file?
      true
    end
    
    def self.get(filename)
      if File.exists? filename
        StubRule.instance
      end
    end
  end
end