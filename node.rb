class Node < GameObject
  attr_accessor :directions, :objects

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
end
