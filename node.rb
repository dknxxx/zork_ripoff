class Node
  attr_accessor :parser, :name, :description, :directions, :objects

  def initialize
    @directions = {}
    @objects = []
  end

  def overview
    # direction_listing = directions.map { |direction, node|
    #   "To the #{direction} you see a #{node.name}"
    # }.join(". ") # TODO do we want this?
    
    active_objects.select(&:scenery).map(&:overview).join("\n")
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
