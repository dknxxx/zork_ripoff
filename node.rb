class Node
  attr_accessor :parser, :name, :description, :directions, :objects

  def initialize
    @directions = {}
    @objects = []
  end

  def active_objects
    @objects.select(&:active)
  end

  def link(other_node, direction)
    @directions[direction] = other_node
  end

  def get(direction)
    @directions[direction]
  end

  def process_input(input)
    @parser.parse(input) if @parser
  end
end
