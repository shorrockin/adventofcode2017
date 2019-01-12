require './boilerplate'

Grid = Struct.new(:data) do
  def flip; Grid.new(data.map(&:reverse)); end
  def size; data.length; end
  def divisible?(amount); size % amount == 0; end

  def rotate(rotations=1)
    rotated_data = data
    rotations.times {rotated_data = rotated_data.last.zip(*rotated_data[0..-2].reverse)}
    Grid.new(rotated_data)
  end

  def partition(partition_size)
    raise "invalid partition size" unless divisible?(partition_size)
    partitions = size / partition_size
    return [[self]] if partitions == 1
    partitions.times.map do |row|
      partitions.times.map do |col|
        Grid.new(data[row * partition_size...(row+1)*partition_size].map { |data| data[col*partition_size...(col+1)*partition_size] })
      end
    end
  end

  def self.merge(partitions)
    Grid.new(partitions.map do |partition_row|
      partition_row[0].size.times.map do |index|
        partition_row.map {|grid| grid.data[index]}.flatten
      end
    end.flatten(1))
  end

  def self.from_str(line)
    rows_str = line.split("/")
    Grid.new(
      rows_str.map do |row|
        row.chars.map {|c| c == '#' ? 1 : 0}
      end
    )
  end

  def count_on
    data.flatten.count {|n| n == 1}
  end
end

Rule = Struct.new(:source, :result) do
  def matches?(grid)
    4.times do
      grid = grid.rotate(1)
      return true if grid == source
      return true if grid.flip == source
    end
    return false
  end

  def self.from_str(str)
    source_str, result_str = str.split("=>").map(&:strip)
    Rule.new(Grid.from_str(source_str), Grid.from_str(result_str))
  end
end

class State < Boilerstate
  attr_accessor :grid, :rules
  def parse(grid)
    @grid = grid
    @rules = @options[:rules]
  end

  def tick(iterations=1)
    iterations.times do
      partitions = case [@grid.divisible?(2), @grid.divisible?(3)]
      when [true, true] then @grid.partition(2)
      when [true, false] then @grid.partition(2)
      when [false, true] then @grid.partition(3)
      else; next
      end

      @grid = Grid.merge(partitions.map do |partition_row|
        partition_row.map do |partition|
          rule = @rules.detect {|r| r.matches?(partition)}
          rule.nil? ? partition : rule.result
        end
      end)
    end
    @grid
  end
end

STARTING_GRID = Grid.new([
  [0, 1, 0],
  [0, 0, 1],
  [1, 1, 1],
])

EXAMPLE_RULES = """../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#""".split("\n").map {|line| Rule.from_str(line)}

INPUT_RULES = input.map {|line| Rule.from_str(line)}

part 1 do
  assert_call_on(STARTING_GRID, Grid.new([[1, 0, 0], [1, 0, 1], [1, 1, 0]]), :rotate, 1)
  assert_call_on(STARTING_GRID, Grid.new([[1, 1, 1], [1, 0, 0], [0, 1, 0]]), :rotate, 2)
  assert_call_on(STARTING_GRID, Grid.new([[0, 1, 0], [1, 0, 0], [1, 1, 1]]), :flip)
  assert_call_on(Grid.new([[1, 0], [1, 1]]), Grid.new([[1, 1], [1, 0]]), :rotate, 1)
  assert_call_on(STARTING_GRID, 3, :size)

  assert_call_on(Rule.new(STARTING_GRID.rotate(2).flip, nil), true, :matches?, STARTING_GRID)
  assert_call_on(Rule.new(Grid.new([[1, 0], [1, 1]]), nil), false, :matches?, STARTING_GRID)

  four_by_four = Grid.new([
    [0, 1, 1, 0],
    [1, 1, 0, 1],
    [1, 0, 1, 1],
    [0, 0, 0, 1],
  ])
  partitions = four_by_four.partition(2)
  assert_call_on(partitions[0], Grid.new([[0, 1], [1, 1]]), :[], 0)
  assert_call_on(partitions[0], Grid.new([[1, 0], [0, 1]]), :[], 1)
  assert_call_on(partitions[1], Grid.new([[1, 0], [0, 0]]), :[], 0)
  assert_call_on(partitions[1], Grid.new([[1, 1], [0, 1]]), :[], 1)
  assert_call_on(Grid, four_by_four, :merge, partitions)
  assert_call_on(Rule, Rule.new(STARTING_GRID, Grid.new([[1,0,0,1],[0,0,0,0],[0,0,0,0],[1,0,0,1]])), :from_str, ".#./..#/### => #..#/..../..../#..#")
  assert_call_on(EXAMPLE_RULES, 2, :length)

  expected_grid = Grid.new([
    [1,1,0,1,1,0],
    [1,0,0,1,0,0],
    [0,0,0,0,0,0],
    [1,1,0,1,1,0],
    [1,0,0,1,0,0],
    [0,0,0,0,0,0],
  ])
  assert_call_on(State.new(STARTING_GRID, rules: EXAMPLE_RULES), expected_grid, :tick, 2)
  assert_call_on(State.new(STARTING_GRID, rules: EXAMPLE_RULES).tick(2), 12, :count_on)

  # actual question
  log_call_on(State.new(STARTING_GRID, rules: INPUT_RULES).tick(5), :count_on)
end

part 2 do
  log_call_on(State.new(STARTING_GRID, rules: INPUT_RULES).tick(18), :count_on)
end
