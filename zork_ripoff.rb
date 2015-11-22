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
    @input_handler.call(input) if @input_handler
  end
end

class GameObject
  attr_accessor :name, :description

  def initialize(&input_handler)
    @input_handler = input_handler
  end

  def process_input(input)
    @input_handler.call(input) if @input_handler
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

def load_image  (image_name)
  path = "images/#{image_name}.txt"
  File.open(path, 'rb') { |f| f.read } if File.exists? path
end

inventory = []

wasteland = Node.new do |input|
  false
end

town = Node.new do |input|
  false
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

dead_clown = GameObject.new do |input|
  result = true

  if input =~ /take wig/
    puts 'You take the wig.'
    town.objects.delete(dead_clown)
    inventory.push('clown wig')
  else
    result = false
  end

  result
end
dead_clown.name = 'dead clown'
dead_clown.description = 'you killed him. he has a bloody wig on'

clown = GameObject.new do |input|
  result = true

  if input =~ /approach/
    puts 'The clown tries to kill you. You hit back and kill it first.'
    town.objects.delete(clown)
    town.objects.push(dead_clown)
  else
    result = false
  end

  result
end
clown.name = 'clown'
clown.description = 'a crazy clown'
town.objects.push(clown)

link_bidrectional(wasteland, town, :east)

current_node = wasteland
continue = true
print_location_name current_node
puts current_node.description
while continue do
  print '>'
  input = gets.chomp
  input_handled = current_node.process_input(input)

  i = 0
  while not input_handled and i < current_node.objects.length do
    input_handled = current_node.objects[i].process_input(input)
    i += 1
  end

  if not input_handled
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
    elsif input =~ /see (.*)/
      object = current_node.objects.find { |obj| obj.name == $1 }
      if object
        image = load_image(object.name)
        puts image || "It looks like a #{object.name}"
      else
        puts "What is a #{object}?"
      end
    elsif input =~ /look/
      object_listing = current_node.objects.map { |object|
        "You see a #{object.name}"
      }.join(". ")
      direction_listing = current_node.directions.map { |direction, node|
        "To the #{direction} you see a #{node.name}"
      }.join(". ")
      puts "#{object_listing}. #{direction_listing}."
    elsif input =~ /inventory/
      if inventory.any?
        items_listed = inventory.map { |item| "a #{item}" }.join(', ')
        puts "In your inventory, you have: #{items_listed}."
      else
        puts "In your inventory, you have nothing."
      end
    else
      puts "I do not understand."
    end
  end

  print "\n"
end
