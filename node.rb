class Node < GameObject
  attr_accessor :directions, :objects

  def initialize(&block)
    super(&block)
    @directions = {}
    @objects = []
  end

  def active_objects
    @objects.map(&:active)
  end

  def link(other_node, direction)
    @directions[direction] = other_node
  end

  def get(direction)
    @directions[direction]
  end
end
