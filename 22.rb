require './boilerplate'
require 'set'

module Status
  Clean =  :clean
  Weakened = :weakened
  Infected = :infected
  Flagged = :flagged
end

module Facing
  North = [-1, 0] # row, col
  South = [1, 0]
  East  = [0, 1]
  West  = [0, -1]
end

Grid = Struct.new(:middle, :states, :flow) do
  def self.from_str(rows, flow)
    states = {}
    rows.each_with_index do |row, row_num|
      row.chars.each_with_index do |char, col_num|
        states[[row_num, col_num]] = Status::Infected if char == '#'
      end
    end
    Grid.new(rows.length / 2, states, flow)
  end

  def is?(row, col, state); states[[row, col]] == state; end
  def state_at(row, col); states[[row, col]] || Status::Clean; end
  def next_state(from); flow[(flow.index(from) + 1) % flow.length]; end

  def toggle(row, col)
    next_state = next_state(state_at(row, col))
    if Status::Clean == next_state
      states.delete([row, col])
      return false
    else
      states[[row, col]] = next_state
      return next_state == Status::Infected
    end
  end
end

Carrier = Struct.new(:row, :col, :facing) do
  def move
    self.row += facing[0]
    self.col += facing[1]
  end
end

PART_ONE_FLOW = [Status::Clean, Status::Infected]
PART_TWO_FLOW = [Status::Clean, Status::Weakened, Status::Infected, Status::Flagged]

def example_grid(flow = PART_ONE_FLOW); Grid.from_str("""..#
#..
...""".split("\n"), flow); end

def input_grid(flow = PART_ONE_FLOW); Grid.from_str(input, flow); end

class State
  include Loggable
  attr_accessor :grid, :infections
  def initialize(grid, logging: false)
    @grid = grid
    @logging = logging
    @carrier = Carrier.new(@grid.middle, @grid.middle, Facing::North)
    @infections = 0
  end

  def turn_right
    @carrier.facing = case @carrier.facing
    when Facing::North then Facing::East
    when Facing::East then Facing::South
    when Facing::South then Facing::West
    when Facing::West then Facing::North
    end
  end

  def turn_left
    @carrier.facing = case @carrier.facing
    when Facing::North then Facing::West
    when Facing::West then Facing::South
    when Facing::South then Facing::East
    when Facing::East then Facing::North
    end
  end

  def turn_reverse
    @carrier.facing = case @carrier.facing
    when Facing::North then Facing::South
    when Facing::West then Facing::East
    when Facing::South then Facing::North
    when Facing::East then Facing::West
    end
  end

  def tick(iterations=1)
    iterations.times do
      case @grid.state_at(@carrier.row, @carrier.col)
      when Status::Infected then turn_right
      when Status::Clean then turn_left
      when Status::Flagged then turn_reverse
      end
      @infections += 1 if @grid.toggle(@carrier.row, @carrier.col)
      @carrier.move
    end

    @infections
  end
end

part 1 do
  assert_call_on(example_grid, true, :is?, 0, 2, Status::Infected)
  assert_call_on(example_grid, false, :is?, 0, 0, Status::Infected)
  assert_call_on(example_grid, true, :is?, 1, 0, Status::Infected)
  assert_call_on(State.new(example_grid), 41, :tick, 70)
  assert_call_on(State.new(example_grid), 5587, :tick, 10000)
  log_call_on(State.new(input_grid), :tick, 10000)
end

part 2 do
  assert_call_on(State.new(example_grid(PART_TWO_FLOW)), 26, :tick, 100)
  assert_call_on(State.new(example_grid(PART_TWO_FLOW)), 2511944, :tick, 10000000)
  log_call_on(State.new(input_grid(PART_TWO_FLOW)), :tick, 10000000)
end
