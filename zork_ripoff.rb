puts "Hello. What is your name?"
# name = gets.chomp

# puts "Welcome #{name}."

class Node
  attr_accessor :name

  def initialize(name)
    @name = name
    @directions = {}
  end

  def link(other_node, direction)
    @directions[direction] = other_node
  end

  def get(direction)
    @directions[direction]
  end
end

def invert_direction(direction)
  case direction
  when :north
    :south
  when :south
    :north
  when :east
    :west
  when :west
    :east
  else
    direction
  end
end

def link_bidrectional(node_a, node_b, direction_to_node_b)
  node_a.link(node_b, direction_to_node_b)
  node_b.link(node_a, invert_direction(direction_to_node_b))
end

start = Node.new 'start'
town = Node.new 'town'

link_bidrectional(start, town, :east)

puts start.get(:east).name