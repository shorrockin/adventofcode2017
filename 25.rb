require './boilerplate'

EXAMPLE_INPUT = """Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.""".split("\n")

Instructions = Struct.new(:starting, :checksum, :conditions)
Condition = Struct.new(:state, :value, :write, :direction, :continue)

def parse(lines)
  starting = /Begin in state (.*)./.match(lines[0])[1]
  checksum = /Perform a diagnostic checksum after (.*) steps/.match(lines[1])[1].to_i
  conditions = []
  line = 3

  extract = lambda do |pattern|
    line += 1
    pattern.match(lines[line - 1])
  end

  while line < lines.length
    state = extract.call(/In state (.*):/)[1]
    2.times do
      value = extract.call(/If the current value is (.*)./)[1].to_i
      write = extract.call(/Write the value (.*)./)[1].to_i
      direction = extract.call(/Move one slot to the (.*)./)[1].to_sym
      continue = extract.call(/Continue with state (.*)./)[1]
      conditions << Condition.new(state, value, write, direction, continue)
    end
    line += 1
  end

  Instructions.new(
    starting,
    checksum,
    conditions.map {|c| [[c.state, c.value], c]}.to_h
  )
end

class Tape
  attr_accessor :state, :values, :index
  def initialize(instructions)
    @state = instructions.starting
    @values = [0]
    @index = 0
    @instructions = instructions
  end

  def right
    if @index + 1 == @values.length
      @values << 0
    end
    @index += 1
  end

  def left
    if @index == 0
      @values.unshift(0)
      @index
    else
      @index -= 1
    end
  end

  def run
    @instructions.checksum.times do
      condition = @instructions.conditions[[@state, current]]
      @values[@index] = condition.write
      self.send(condition.direction)
      @state = condition.continue
    end

    @values.count {|v| v == 1}
  end

  def current; @values[@index]; end
end

part 1 do
  instructions = parse(EXAMPLE_INPUT)
  assert_call_on(instructions, "A", :starting)
  assert_call_on(instructions, 6, :checksum)
  assert_call_on(instructions.conditions, 4, :length)
  assert_call_on(instructions.conditions, Condition.new("A", 0, 1, :right, "B"), :[], ["A", 0])
  assert_call_on(instructions.conditions, Condition.new("A", 1, 0, :left, "B"), :[], ["A", 1])
  assert_call_on(instructions.conditions, Condition.new("B", 0, 1, :left, "A"), :[], ["B", 0])
  assert_call_on(instructions.conditions, Condition.new("B", 1, 1, :right, "A"), :[], ["B", 1])

  tape = Tape.new(instructions)
  assert_call_on(tape, 3, :run)
  assert_call_on(tape, [1, 1, 0, 1], :values)
  assert_call_on(tape, 2, :index)

  tape = Tape.new(parse(input))
  log_call_on(tape, :run)
end
