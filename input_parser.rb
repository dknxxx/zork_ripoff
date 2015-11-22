class InputParser
  def initialize(&block)
    @patterns = []
    @self_before_instance_eval = eval "self", block.binding
    instance_eval &block
  end

  def add(regex, &block)
    @patterns.push([regex, block])
  end

  def parse(input)
    match = @patterns.find { |pattern| input =~ pattern[0] }
    match[1].call(input.match match[0]) if match
    not match.nil?
  end

  def method_missing(method, *args, &block)
    @self_before_instance_eval.send method, *args, block
  end
end
