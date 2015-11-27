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
    puts "#======== #{node.name} ========#"
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
        object = current_node.active_objects.find { |obj| obj.name.downcase == match[2].downcase }
        if object
          puts object.description
        else
          puts "What is a #{object}?"
        end
      }
      add(/see (.*)/i) { |match|
        object = current_node.active_objects.find { |obj| obj.name.downcase == match[1].downcase }
        if object
          puts load_image(object.name) || "It looks like a #{object.name}"
        else
          puts "What is a #{object}?"
        end
      }
      add(/take (.*)/i) { |match|
        object = current_node.active_objects.find { |obj| obj.name.downcase == match[1].downcase }
        if object
          if object.can_take
            puts "You pick up #{object.name}."
            inventory.push(object.name)
            current_node.objects.delete(object)
            object.do_action('take')
          else
            puts "You can't pick up #{object.name}."
          end
        else
          puts "What is a #{object}?"
        end
      }
      # TODO drop object
      add(/look/i) { |match|
        scenery_objects = current_node.active_objects.select(&:scenery)
        object_listing = scenery_objects.map(&:overview).join("\n")

        direction_listing = current_node.directions.map { |direction, node|
          "To the #{direction} you see a #{node.name}"
        }.join(". ")
        
        puts object_listing
        # puts direction_listing # TODO do we want this?
      }
      add(/inventory/i) { |match|
        if inventory.any?
          items_listed = inventory.map { |item| "a #{item}" }.join(', ')
          puts "In your inventory, you have: #{items_listed}."
        else
          puts "In your inventory, you have nothing."
        end
      }
      add(/.*/) { |match|
        # try to perform an action...
        object_to_act_on = current_node.active_objects.find { |object|
          action_match = match[0].match(/(.*) (#{object.name})/i)
          object.has_action?(action_match[1]) if action_match
        }
        if object_to_act_on
          action = match[0].match(/(.*) (#{object_to_act_on.name})/i)[1]
          object_to_act_on.do_action(action)
        else
          puts "I do not understand"
        end
      }
    end

    while @continue do
      print '>'
      input = gets.chomp.strip
      input_handled = current_node.process_input(input)

      i = 0
      active_objects = current_node.active_objects
      while not input_handled and i < active_objects.length do
        input_handled = active_objects[i].process_input(input)
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
  when :northeast
    :southwest
  when :northwest
    :southeast
  when :southwest
    :northeast
  when :southeast
    :northwest
  else
    direction
  end
end
