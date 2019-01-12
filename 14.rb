require './boilerplate'
require 'set'

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

  def dense_binary_hash(partition_size: 16)
    (@data.length / partition_size).times.map do |partition|
      starting_index = partition_size * partition
      @data[starting_index...starting_index+partition_size].reduce(0) {|m, v| m ^ v}
    end.map do |value|
      hex = sprintf("%02X", value)
      hex.chars.map {|c| c.hex.to_s(2).rjust(4, '0')}.join
    end.join.downcase
  end
end

def create_grid(input)
  128.times.map do |i|
    State.new("#{input}-#{i}", as_ascii: true, input_append: PART_TWO_APPEND, rounds: 64).dense_binary_hash
  end
end

def count_regions(grid)
  checked = [].to_set
  count = 0
  128.times do |row|
    128.times do |col|
      unless checked.include?([row, col])
        if grid[row][col] == '1'
          checked = fill_region(checked, grid, row, col)
          count += 1
        end
      end
    end
  end

  count
end

def fill_region(checked, grid, row, col)
  unless checked.include?([row, col])
    if row >= 0 && row < 128 && col >= 0 && col < 128
      if grid[row][col] == '1'
      checked << [row, col]
      checked = fill_region(checked, grid, row, col + 1)
      checked = fill_region(checked, grid, row, col - 1)
      checked = fill_region(checked, grid, row - 1, col)
      checked = fill_region(checked, grid, row + 1, col)
      end
    end
  end
  checked
end


part "1/2" do
  grid = create_grid("flqrgnkx")
  assert_equal(8108, grid.join.chars.count {|c| c == "1"}, "count == '1'")
  assert_call(1242, :count_regions, grid)

  grid = create_grid("amgozmfv")
  assert_equal(8222, grid.join.chars.count {|c| c == "1"}, "count == '1'")
  log_call(:count_regions, grid)
end
