require './boilerplate'

DEFAULT_SIZE = 256
PART_TWO_APPEND = [17, 31, 73, 47, 23]

class State
  include Loggable
  attr_accessor :data, :lengths, :current, :skip_size

  def initialize(input, size: DEFAULT_SIZE, logging: false, as_ascii: false, input_append: [], rounds: 1)
    @logging   = logging
    @current   = 0
    @data      = size.times.map(&:to_i)
    @skip_size = 0

    input = as_ascii ? input.chars.map(&:ord) : input.split(",").map(&:to_i)
    input = input + input_append

    rounds.times do
      input.each do |length|
        range = length.times.map {|l| get(l + @current)}.reverse
        length.times.each {|l| set(l + @current, range[l])}
        @current += ((length + @skip_size) % @data.length)
        @skip_size += 1
      end
    end
  end

  def get(index); @data[index % @data.length]; end
  def set(index, val); @data[index % data.length] = val; end
  def first_two_products; @data[0] * @data[1]; end

  def dense_hash(partition_size: 16)
    (@data.length / partition_size).times.map do |partition|
      starting_index = partition_size * partition
      @data[starting_index...starting_index+partition_size].reduce(0) {|m, v| m ^ v}
    end.map do |value|
      sprintf("%02X", value)
    end.join.downcase
  end
end

part "1" do
  state = State.new("3, 4, 1, 5", size: 5)
  assert_call_on(state, 12, :first_two_products)

  state = State.new(input)
  log_call_on(state, :first_two_products)
end

part "2" do
  state = State.new("1,2,3", as_ascii: true, input_append: PART_TWO_APPEND, rounds: 64)
  assert_call_on(state, "3efbe78a8d82f29979031a4aa0b16a9d", :dense_hash)

  state = State.new("1,2,4", as_ascii: true, input_append: PART_TWO_APPEND, rounds: 64)
  assert_call_on(state, "63960835bcdc130f0b66d7ff4f6a5a8e", :dense_hash)

  state = State.new(input.strip, as_ascii: true, input_append: PART_TWO_APPEND, rounds: 64)
  log_call_on(state, :dense_hash)
end
