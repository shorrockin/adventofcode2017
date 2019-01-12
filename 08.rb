require './boilerplate'

INST_REGEX = /(\w+) (inc|dec) (-?\d+) if (\w+) (.+) (-?\d+)/

COMPARATORS = {
  ">"  => lambda {|l, r| l > r},
  "<"  => lambda {|l, r| l < r},
  "==" => lambda {|l, r| l == r},
  "!=" => lambda {|l, r| l != r},
  ">=" => lambda {|l, r| l >= r},
  "<=" => lambda {|l, r| l <= r},
}

Instruction = Struct.new(:register, :amount, :condition)
Condition = Struct.new(:register, :comparator, :amount)

class State
  include Loggable
  attr_accessor :instruction, :registers, :highest_register
  def initialize(input, logging: false)
    @logging          = logging
    @registers        = {}
    @highest_register = 0
    @instructions     = input.map {|line| parse_line(line)}

    @instructions.each do |i|
      condition = i.condition

      if condition.comparator.call(register_value(condition.register), condition.amount)
        @registers[i.register] ||= 0
        @registers[i.register] += i.amount
        @highest_register = @registers[i.register] if @registers[i.register] > @highest_register
      end
    end
  end

  def instruction_count; @instructions.length; end
  def register_value(register); @registers[register] || 0; end
  def largest_register; @registers.values.sort.last; end
  def highest_register_ever; @highest_register; end

  private def parse_line(line)
    match     = INST_REGEX.match(line)
    condition = Condition.new(match[4], COMPARATORS[match[5]], match[6].to_i)
    amount    = match[3].to_i
    amount    = amount * -1 if match[2] == "dec"
    inst      = Instruction.new(match[1], amount, condition)
    log "created instruction:", inst
    inst
  end
end

part "1 (example 1)" do
  state = State.new([
    "b inc 5 if a > 1",
    "a inc 1 if b < 5",
    "c dec -10 if a >= 1",
    "c inc -20 if c == 10",
  ], logging: false)

  assert_call_on(state, 4, :instruction_count)
  assert_call_on(state, 1, :largest_register)
  assert_call_on(state, 10, :highest_register_ever)
end

part "1" do
  state = State.new(input)
  log_call_on(state, :largest_register)
  log_call_on(state, :highest_register_ever)
end
