require './boilerplate'

class State
  include Loggable
  attr_accessor :score, :garbage
  def initialize(input, logging: false)
    @logging = logging
    @score   = 0
    @garbage = 0
    parse(input.chars.each)
  end

  private def parse(enum)
    begin
      in_garbage = false
      group = 0

      while true
        case [enum.next, in_garbage]
        when ["{", false] then group += 1
        when ["}", false] then @score += group; group -= 1
        when ["!", true] then enum.next
        when ["<", false] then in_garbage = true
        when [">", true] then in_garbage = false
        else; @garbage += 1 if in_garbage; end
      end
    rescue StopIteration
      log "iteration complete"
    end
  end
end

part "1 (examples)" do
  assert_call_on(State.new("{}"), 1, :score)
  assert_call_on(State.new("{{{}}}"), 6, :score)
  assert_call_on(State.new("{{},{}}"), 5, :score)
  assert_call_on(State.new("{{{},{},{{}}}}"), 16, :score)
  assert_call_on(State.new("{<a>,<a>,<a>,<a>}"), 1, :score)
  assert_call_on(State.new("{{<ab>},{<ab>},{<ab>},{<ab>}}"), 9, :score)
  assert_call_on(State.new("{{<!!>},{<!!>},{<!!>},{<!!>}}"), 9, :score)
  assert_call_on(State.new("{{<a!>},{<a!>},{<a!>},{<ab>}}"), 3, :score)
end

part "1/2" do
  state = State.new(input)
  log_call_on(state, :score)
  log_call_on(state, :garbage)
end
