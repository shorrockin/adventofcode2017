require './boilerplate'

Layer = Struct.new(:depth, :range) do
  def severity; range * depth; end
  def travel_distance; range + (range - 2); end
  def position_at(time); time = time % travel_distance; time < range ? time : range - (time % range) - 2; end
end


class State < Boilerstate
  attr_accessor :layers

  def parse(input)
    @layers = {}
    input.each do |line|
      parts = line.split(":")
      @layers[parts[0].to_i] = Layer.new(parts[0].to_i, parts[1].to_i)
    end
  end

  def max_depth; @layers.values.map(&:depth).max; end

  def severity_sum(delay = 0); severity(delay).sum; end

  def severity(delay = 0)
    out = []
    (max_depth+1).times.map do |time|
      if @layers[time]&.position_at(time + delay) == 0
        out << @layers[time].severity
      end
    end
    out
  end
end

part "Layer Test" do
  layer = Layer.new(0, 4)
  assert_call_on(layer, 0, :position_at, 0)
  assert_call_on(layer, 1, :position_at, 1)
  assert_call_on(layer, 2, :position_at, 2)
  assert_call_on(layer, 3, :position_at, 3)
  assert_call_on(layer, 2, :position_at, 4)
  assert_call_on(layer, 1, :position_at, 5)
  assert_call_on(layer, 0, :position_at, 6)

  layer = Layer.new(0, 3)
  assert_call_on(layer, 0, :position_at, 0)
  assert_call_on(layer, 1, :position_at, 1)
  assert_call_on(layer, 2, :position_at, 2)
  assert_call_on(layer, 1, :position_at, 3)
  assert_call_on(layer, 0, :position_at, 4)
  assert_call_on(layer, 1, :position_at, 5)
  assert_call_on(layer, 2, :position_at, 6)
end

part "1/2 (example)" do
  state = State.new("""0: 3
1: 2
4: 4
6: 4""".split("\n"), logging: false)

  assert_call_on(state.layers, 4, :length)
  assert_call_on(state.layers[0], 0, :depth)
  assert_call_on(state.layers[0], 3, :range)
  assert_call_on(state.layers[6], 6, :depth)
  assert_call_on(state.layers[6], 4, :range)
  assert_call_on(state, 6, :max_depth)
  assert_call_on(state, 24, :severity_sum)
  assert_call_on(state, 0, :severity_sum, 10)

  delay = 0
  delay += 1 while 0 != state.severity(delay).length
  assert_equal(10, delay, "calculated delay")
  assert_call_on(state, 0, :severity_sum, delay)
end

part "1/2" do
  state = State.new(input)
  log_call_on(state, :severity_sum)

  delay = 0
  delay += 1 while 0 != state.severity(delay).length
  log_call_on(state, :severity_sum, delay)
end
