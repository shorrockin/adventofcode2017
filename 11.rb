require './boilerplate'

DIRECTIONS = {
  'n' => [0, 1],
  's' => [0, -1],
  'ne' => [1, 1],
  'nw' => [-1, 0],
  'se' => [1, 0],
  'sw' => [-1, -1],
}

class State
  attr_accessor :x, :y, :max_distance
  def initialize(input)
    @x = 0
    @y = 0
    @max_distance = 0

    input.split(',').each do |direction|
      @x = @x + DIRECTIONS[direction][0]
      @y = @y + DIRECTIONS[direction][1]
      @max_distance = [distance_from(0, 0), @max_distance].max
    end
  end

  def distance_from(x, y)
    dx = @x - x
    dy = @y - y
    [dx.abs, dy.abs, (dx - dy).abs].max
  end
end

part "1" do
  assert_call_on(State.new('ne,ne,ne'), 3, :distance_from, 0, 0)
  assert_call_on(State.new('nw,nw,nw'), 3, :distance_from, 0, 0)
  assert_call_on(State.new('ne,ne,sw,sw'), 0, :distance_from, 0, 0)
  assert_call_on(State.new('ne,ne,s,s'), 2, :distance_from, 0, 0)
  assert_call_on(State.new('se,sw,se,sw,sw'), 3, :distance_from, 0, 0)
  assert_call_on(State.new('n,sw,s,se,ne,n,nw,s'), 0, :distance_from, 0, 0)
  assert_call_on(State.new('s,se,se,se,se'), 5, :distance_from, 0, 0)
  assert_call_on(State.new('s,se,s,s,se,s'), 6, :distance_from, 0, 0)

  state = State.new(input.strip)
  log_call_on(state, :x)
  log_call_on(state, :y)
  log_call_on(state, :distance_from, 0, 0)
  log_call_on(state, :max_distance)
end
