class GameObject
  attr_accessor :parser, :name, :overview, :description, :active, :scenery, :can_take

  def initialize
    @actions = {}
    @active = true
    @scenery = true
    @can_take = false
  end

  def overview
    @overview || "You see a #{name}"
  end

  def on_action(regex, &block)
    @actions[regex] = block
  end

  def do_action(action)
    regex = @actions.keys.find { |regex|
      action =~ regex
    }
    @actions[regex].call if regex
  end

  def has_action?(action)
    @actions.keys.any? { |regex|
      action =~ regex
    }
  end

  def process_input(input)
    @parser.parse(input) if @parser
  end
end
