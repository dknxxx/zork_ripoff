class Node < GameObject
  attr_accessor :directions, :objects

  def initialize(&input_handler)
    super(&input_handler)
    @directions = {}
    @objects = []
  end

  def link(other_node, direction)
    @directions[direction] = other_node
  end

  def get(direction)
    @directions[direction]
  end
end
