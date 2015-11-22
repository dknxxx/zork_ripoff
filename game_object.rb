class GameObject
  attr_accessor :name, :description

  def initialize(&block)
    @input_parser = InputParser.new &block if block
  end

  def process_input(input)
    @input_parser.parse(input) if @input_parser
  end
end
