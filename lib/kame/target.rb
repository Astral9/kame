require 'kame/utils/config'
require 'kame/utils/logging'
require 'kame/utils/functional'
require 'kame/algorithm/core'

require 'singleton'
require 'set'

module Kame
  class Target
    include Kame::Config
    include Kame::Logging
    include Kame::Functional
    include Kame::Algorithm
    
    def initialize
      @rules = []
    end
    
    def make(rule)
      exec(rule)
      
      Kame::Shortcuts::pexit(0)
    end
      
    def rule(pat, options = {}, &block)
      raise "No action for rule \"#{pat}\"." unless block_given?
      
      @rules << Rule.new(pat, options, block)
    end
    
    def exec(s)
      graph = Graph.new
      
      rule = find_rule s
      raise "No rule for making \"#{s}\". Stop." unless rule
      if rule.needs_update? s
        node = Node.new s, rule
        
        graph.add_node(node)
        build_graph s, graph, node, rule
        
        jobs = graph.sort
        exec_jobs jobs
      else
        truify(info "#{s} is up to date.")
      end
    end
    
    private
    def build_graph(s, g, n, rule)
      return unless rule.needs_update? (s)
      
      matches = rule.match(s)[1..-1]
      
      filled_deps = []
      rule.deps.each do |dep|
        dep = dep.dup
        matches.each { |m| dep.sub!(/%/, m) }
        filled_deps << dep
        
        dep_rule = find_rule dep
        if dep_rule.needs_update? dep
          dep_node = g.has_node?(dep) ? g.get_node(dep) : g.add_node(Node.new(dep, dep_rule))
          build_graph dep, g, dep_node, dep_rule if n.add_edge dep_node
        end
      end
      
      n.args = filled_deps
    end
    
    def exec_jobs(jobs)
      jobs.each do |job|
        unless job.rule.exec_rule job.name, job.args
          return false
        end
      end
      
      true
    end
    
    def find_rule(s)
      # either there is such rule
      @rules.find { |r| r.match? s } ||
      # or there is such file 
      StubRule.get(s)
    end
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
      return true if @options[:mode] & RuleMode::FORCE_REBUILD > 0
      
      !(File.exists? s)
    end
    
    def match?(s)
      @regex.match s
    end
    alias match match?
    
    def exec_rule(s, filled_deps)
      #error "Pretending to be executing action for #{s}, and received args #{filled_deps}"
      act = @action_proc[s, *filled_deps]
      act.config_delegate = self
      
      act.run!
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