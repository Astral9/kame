require 'kame/utils/logging'
require 'kame/utils/functional'

require 'set'

module Kame
  module Algorithm
  
    class Graph
      def initialize
        @nodes = {}
      end
      
      def has_node?(name)
        @nodes.include? name
      end
      
      def get_node(name)
        @nodes[name]
      end
      
      def add_node(node)
        @nodes[node.name] = node
        node
      end
  
      def sort
        preserve_node_states!
        
        queue = []
        
        values = @nodes.values
        fringe = values.select { |node| node.degree == 0 }
        
        until fringe.empty?
          node = fringe.shift
          queue << node
          
          node.outgoing_edges.each do |n|
            node.outgoing_edges.delete n
            n.incoming_edges.delete node
            
            if n.degree == 0
              fringe << n
            end
          end
        end
        
        queue
      end
      
      private
      def preserve_node_states!
        @nodes.values.each(&:preserve_state!)
      end
    end
    
    class Node
      include Kame::Logging
      include Kame::Functional
      
      attr_reader :name, :rule, :incoming_edges, :outgoing_edges
      attr_reader :dependencies
      
      attr_accessor :built
      
      def initialize(name, rule)
        @name = name
        @rule = rule
        raise "Trying to initialise a node (#{name}) with empty rule." unless rule
        
        @incoming_edges = Set.new
        @outgoing_edges = Set.new
        
        @built = false
      end
      
      def add_edge(node)
        if will_introduce_cycle? node
          falsify(warning "Cyclic dependency found: #{name} -> #{node.name}. Dropping.")
        else
          truify(-> { @incoming_edges << node; node.outgoing_edges << self }[])
        end
      end
      
      def degree
        @incoming_edges.size
      end
      
      def preserve_state!
        @dependencies = @incoming_edges.to_a
      end
      
      private
      def will_introduce_cycle?(new_node)
        return true if new_node == self
        
        # otherwise
        new_node.incoming_edges.any? { |d| will_introduce_cycle? d }
      end
      
    end
    
  end
end