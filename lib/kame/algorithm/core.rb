
module Kame
  module Algorithm
  
    class Graph
      def initialize
        @nodes = {}
      end
      
      def get_node(name, rule=nil)
        @nodes[name] ||= Node.new(name, rule)
      end
      
      def sort
        
      end
    end
    
    class Node
      attr_reader :name, :rule, :neighbours
      
      def initialize(name, rule)
        @name = name
        @rule = rule
        raise "Trying to initialise a node (#{name}) with empty rule." unless rule
        
        @neighbours = []
        define_method :add_neighbour, &@neighbours.method(:<<)
      end
      
      def degree
        @neighbours.size
      end
    end
    
  end
end