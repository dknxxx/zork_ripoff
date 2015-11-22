class GameObject
  attr_accessor :name, :description

  def initialize(&input_handler)
    @input_handler = input_handler
  end

  def process_input(input)
    @input_handler.call(input) if @input_handler
  end
end
