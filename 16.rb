require './boilerplate'
require 'set'

class State < Boilerstate
  attr_accessor :commands
  def parse(input)
    @commands = input.split(",").map do |line|
      case line[0]
      when 's' then [:split, line[1..-1].to_i]
      when 'x' then [:exchange, line[1..-1].split("/").map(&:to_i)].flatten
      when 'p' then [:partner, line[1..-1].split("/")].flatten
      end
    end
  end

  def dance(programs)
    programs = programs.chars.each_with_index.map {|char, index| [char, index]}.to_h
    @commands.each do |command|
      case command[0]
      when :split then programs.map {|p, i| programs[p] = (i + command[1]) % programs.length}
      when :partner then
        left = programs[command[1]]
        right = programs[command[2]]
        programs[command[1]] = right
        programs[command[2]] = left
      when :exchange
        left = at_position(programs, command[1])
        right = at_position(programs, command[2])
        programs[left] = command[2]
        programs[right] = command[1]
      end
    end

    programs.map {|p, i| [i, p]}.sort.map(&:last).join
  end

  def at_position(programs, position)
    programs.each do |k, v|
      return k if v == position
    end
  end
end

class Repeater
  attr_accessor :rotations
  def initialize
    @rotations = [].to_set
  end

  def repeat(state, positions, times = 1_000_000_000)
    while !@rotations.include?(positions)
      @rotations << positions
      positions = state.dance(positions)
    end

    # assumes it repeats back to initial state, which seems to always be true
    (times % @rotations.length).times {positions = state.dance(positions)}
    positions
  end
end

part 1 do
  state = State.new("s1,x3/4,pe/b")
  assert_call_on(state.commands, 3, :length)
  assert_call_on(state.commands, [:split, 1], :[], 0)
  assert_call_on(state.commands, [:exchange, 3, 4], :[], 1)
  assert_call_on(state.commands, [:partner, 'e', 'b'], :[], 2)
  assert_call_on(state, "baedc", :dance, "abcde")

  state = State.new(input)
  log_call_on(state, :dance, "abcdefghijklmnop")
end

part 2 do
  log_call_on(Repeater.new, :repeat, State.new("s1,x3/4,pe/b"), "abcde")
  log_call_on(Repeater.new, :repeat, State.new(input), "abcdefghijklmnop")
end
