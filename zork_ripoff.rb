# puts "Hello. What is your name?"
# name = gets.chomp

# puts "Welcome #{name}."

class Node
  attr_accessor :name, :directions, :description

  def initialize(&input_handler)
    @directions = {}
    @input_handler = input_handler
  end

  def link(other_node, direction)
    @directions[direction] = other_node
  end

  def get(direction)
    @directions[direction]
  end

  def process_input(input)
    @input_handler.call(input)
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

def print_location_name(node)
  puts "#======== #{node.name} ========"
end

start = Node.new do |input|
  # puts 'bye'
end

town = Node.new do |input|
  # puts 'hi'
end

start.name = 'start'
start.description = 'and so it begins'

town.name = 'town'
town.description = 'I used to be a text adventurer like you, but then I stumbled over my words in the knee.'

link_bidrectional(start, town, :east)

current_node = start
continue = true
print_location_name current_node
puts current_node.description
while continue do
  input = gets.chomp
  current_node.process_input(input)
  if input == "quit"
    continue = false
  elsif input =~ /(go|move) (.*)/
    direction = $2.to_sym
    if current_node.get(direction)
      current_node = current_node.get(direction)
      print_location_name current_node
      puts current_node.description
    else
      puts "There is nothing #{$2}"
    end
  elsif input =~ /where/
    puts current_node.name
  elsif input =~ /look/
    direction_listing = current_node.directions.map { |direction, node|
      "#{direction}: #{node.name}"
    }.join("\n")
    puts "You look around.\n\n#{direction_listing}"
  end
end
