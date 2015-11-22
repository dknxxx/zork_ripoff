# puts "Hello. What is your name?"
# name = gets.chomp

# puts "Welcome #{name}."

class Node
  attr_accessor :name, :directions, :description, :objects

  def initialize(&input_handler)
    @directions = {}
    @objects = []
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

class GameObject
  attr_accessor :name, :description
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

wasteland = Node.new do |input|
  # puts 'bye'
end

town = Node.new do |input|
  # puts 'hi'
end

wasteland.name = 'wasteland'
wasteland.description = 'and so it begins'

statue = GameObject.new
statue.name = 'statue'
statue.description = %q=Two vast and trunkless legs of stone
Stand in the desert. Near them, on the sand,
Half sunk, a shattered visage lies, whose frown,
And wrinkled lip, and sneer of cold command,
Tell that its sculptor well those passions read
Which yet survive, stamped on these lifeless things,
The hand that mocked them and the heart that fed:
And on the pedestal these words appear:
'My name is Ozymandias, king of kings:
Look on my works, ye Mighty, and despair!'
Nothing beside remains. Round the decay
Of that colossal wreck, boundless and bare
The lone and level sands stretch far away.=
wasteland.objects.push(statue)

town.name = 'town'
town.description = 'I used to be a text adventurer like you, but then I stumbled over my words in the knee.'

link_bidrectional(wasteland, town, :east)

current_node = wasteland
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
  elsif input =~ /look (.*)/
    object = current_node.objects.find { |obj| obj.name == $1 }
    if object
      puts object.description
    else
      puts "What is a #{object}?"
    end
  elsif input =~ /look/
    object_listing = current_node.objects.map { |object|
      object.name
    }.join("\n")
    direction_listing = current_node.directions.map { |direction, node|
      "To the #{direction} you see: #{node.name}"
    }.join("\n")
    puts "You look around.\n\n#{object_listing}\n\n#{direction_listing}"
  end
end
