require_relative 'game_object'
require_relative 'node'
require_relative 'input_parser'

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

def load_image(image_name)
  path = "images/#{image_name}.txt"
  File.open(path, 'rb') { |f| f.read } if File.exists? path
end

def ask_question(question, answers)
  answer = nil
  loop do
    puts question
    puts answers.join("\n")

    print '>'
    answer = gets.chomp

    if answers.map { |a| a.downcase }.include?(answer.downcase)
      answer = answers[answers.find_index { |a| a.downcase == answer.downcase }]
      break
    end
    break if answers.map { |a| a.downcase }.include?(answer.downcase)
  end
  answer
end

inventory = []

wasteland = Node.new do |input|
  false
end

town = Node.new do |input|
  false
end

continue = true

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

town.name = 'Former Salt Lake City'
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
dead_clown.description = 'You killed him. He has a bloody wig on'

mayor = GameObject.new do |input|
  if input =~ /talk|speak/
    answer = ask_question('Alas, my brother is dead. A new grain of salt has been added to the pile. You, foreigner, are responsible and must pay the price. Submit?', ['Yes, No'])
    if answer == 'Yes'
      puts 'You are taken to jail'
      current_node = jail_cell
      print_location_name current_node
    elsif answer == 'No'
      puts 'The mob guts you like the beast you are.'
      contine = false
    end
  else
    result = false
  end

  result
end
mayor.name = 'Cameron the Salty'
mayor.description = 'The saltiest of the salties'


angry_mob_directions_left = [:east, :west, :north, :south]
angry_mob = GameObject.new do |input|
  if input =~ /(go|move) (.*)/
    direction = $2.to_sym
    angry_mob_directions_left.delete(direction)
    if angry_mob_directions_left.empty?
      puts "The mayor approaches"
      town.objects.push(mayor)
    else
      puts "The angry mob prevents you from leaving"
    end
  end

  true
end

clown = GameObject.new do |input|
  result = true

  if input =~ /approach/
    answer = ask_question('The clown tries to kill you. Hit back?', ['Yes', 'No'])
    if answer == 'Yes'
      puts 'You kill him.'
      town.objects.delete(clown)
      town.objects.push(dead_clown)
      town.objects.push(angry_mob)
    elsif answer == 'No'
      puts 'You dead.'
      continue = false
    end
  else
    result = false
  end

  result
end
clown.name = 'clown'
clown.description = 'a crazy clown, maybe you should approach him'
town.objects.push(clown)


link_bidrectional(wasteland, town, :east)

current_node = wasteland
print_location_name current_node
puts current_node.description

main_input_parser = InputParser.new do
  add(/quit/) { |match|
    continue = false
  }
  add(/(go|move) (.*)/) { |match|
    direction = match[2].to_sym
    puts direction
    if current_node.get(direction)
      current_node = current_node.get(direction)
      print_location_name current_node
      puts current_node.description
    else
      puts "There is nothing #{direction}"
    end
  }
  add(/look( at)? (.*)/) { |match|
    object = current_node.objects.find { |obj| obj.name == match[2] }
    if object
      puts object.description
    else
      puts "What is a #{object}?"
    end
  }
  add(/see (.*)/) { |match|
    object = current_node.objects.find { |obj| obj.name == match[1] }
    if object
      image = load_image(object.name)
      puts image || "It looks like a #{object.name}"
    else
      puts "What is a #{object}?"
    end
  }
  add(/look/) { |match|
    object_listing = current_node.objects.map { |object|
      "You see a #{object.name}"
    }.join(". ")
    direction_listing = current_node.directions.map { |direction, node|
      "To the #{direction} you see a #{node.name}"
    }.join(". ")
    puts "#{object_listing}. #{direction_listing}."
  }
  add(/inventory/) { |match|
    if inventory.any?
      items_listed = inventory.map { |item| "a #{item}" }.join(', ')
      puts "In your inventory, you have: #{items_listed}."
    else
      puts "In your inventory, you have nothing."
    end
  }
  add(//) { |match|
    puts "I do not understand"
  }
end

while continue do
  print '>'
  input = gets.chomp.strip
  input_handled = current_node.process_input(input)

  i = 0
  while not input_handled and i < current_node.objects.length do
    input_handled = current_node.objects[i].process_input(input)
    i += 1
  end

  if not input_handled
    main_input_parser.parse input
  end

  print "\n"
end
