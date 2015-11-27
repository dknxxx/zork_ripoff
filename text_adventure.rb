require_relative 'game_object'
require_relative 'node'
require_relative 'input_parser'

class TextAdventure
  attr_accessor :current_node, :inventory

  def initialize(&block)
    @self_before_instance_eval = eval "self", block.binding
    instance_eval &block
  end

  def link_bidrectional(node_a, node_b, direction_to_node_b)
    node_a.link(node_b, direction_to_node_b)
    node_b.link(node_a, invert_direction(direction_to_node_b))
  end

  def load_image(image_name)
    path = "images/#{image_name}.txt"
    File.read(path) if File.exists? path
  end

  def ask_question(question, &block)
    answer_parser = InputParser.new &block
    loop do
      puts question
      puts answer_parser.patterns.map(&:first).map(&:source).map(&:capitalize).join("\n")
      print '>'
      answer = gets.chomp.strip
      break if answer_parser.parse answer
    end
  end

  def move_to(node)
    @current_node = node
    puts "#======== #{node.name} ========"
    puts current_node.description
  end

  def end_game
    @continue = false
  end

  def start
    @inventory = []
    @continue = true
    move_to(current_node)

    main_input_parser = InputParser.new do
      add(/quit/i) { |match|
        end_game
      }
      add(/(go|move) (.*)/i) { |match|
        direction = match[2].to_sym
        if current_node.get(direction)
          move_to(current_node.get(direction))
        else
          puts "There is nothing #{direction}"
        end
      }
      add(/look( at)? (.*)/i) { |match|
        object = current_node.objects.find { |obj| obj.name.downcase == match[2].downcase }
        if object
          puts object.description
        else
          puts "What is a #{object}?"
        end
      }
      add(/see (.*)/i) { |match|
        object = current_node.objects.find { |obj| obj.name.downcase == match[1].downcase }
        if object
          puts load_image(object.name) || "It looks like a #{object.name}"
        else
          puts "What is a #{object}?"
        end
      }
      add(/look/i) { |match|
        object_listing = case current_node.objects.size
        when 0
          "You see nothing. "
        when 1
          "You see a #{current_node.objects.first.name}. "
        else
          object_names = (current_node.objects[1..-2].map { |object|
            "a #{object.name}"
          } + ["and a #{current_node.objects[-1].name}"]).join(", ")
          "You see a #{current_node.objects.first.name}, #{object_names}. "
        end

        direction_listing = current_node.directions.map { |direction, node|
          "To the #{direction} you see a #{node.name}"
        }.join(". ")
        
        puts "#{object_listing}#{direction_listing}"
      }
      add(/inventory/i) { |match|
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

    while @continue do
      print '>'
      input = gets.chomp.strip
      input_handled = current_node.process_input(input)

      i = 0
      while not input_handled and i < current_node.objects.length do
        input_handled = current_node.objects[i].process_input(input)
        i += 1
      end

      main_input_parser.parse input if not input_handled

      print "\n"
    end
  end

  def method_missing(method, *args, &block)
    @self_before_instance_eval.send method, *args, block
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
