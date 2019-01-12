# Advent Boilerplate Start
require 'pry'

def test(value, expect, input)
  input = input.to_s.gsub("\n", "\\n").gsub("\t", "\\t")
  if input.length > 60
    input = input.slice(0,57) + '...'
  end

  check = '✓'
  outcome = expect.nil? ? '?' : (value == expect ? check : 'x')
  expect = '""' if expect == ""
  expected = (expect.nil? || outcome == check) ? '' : ", Expected: #{expect}"

  puts "  #{outcome} Value: #{value}#{expected}, Input: #{input}"
  return value
end

def test_call(expect, method, *args)
  result = self.send(method, *args)
  test(result, expect, "#{method}(#{args.to_s[1...-1]})")
end

def input
  @input ||= $<.map(&:to_s).map(&:strip)
  return @input[0] if @input.length == 1 # is this one line?
  @input.dup # prevents previous alteration to array
end

def part(num, &block)
  puts "Part #{num}:"
  yield
  puts ""
end
# Advent Boilerplate End

def input_data
  input.split("\t").map(&:to_i)
end

def example_data
  [0, 2, 7, 0]
end

def max_index_and_val(data)
  index = 0
  val = 0
  data.each_with_index do |d, idx|
    if d > val
      index = idx
      val = d
    end
  end
  [index, val]
end

def redistribute_at!(data, index)
  count = data[index]
  data[index] = 0

  (1..count).each do |iteration|
    to_replace = (index + iteration) % data.length
    data[to_replace] += 1
  end

  data
end

def detect_infinite_loop_data(data)
  history = Hash.new
  count = 0

  while !history.include?(data)
    history[data.dup] = true
    count += 1
    index, _ = max_index_and_val(data)
    redistribute_at!(data, index)
  end

  {count: count, data: data}
end

def detect_loop(data)
  detect_infinite_loop_data(data)[:count]
end

part 1 do
  test_call([2, 7], :max_index_and_val, example_data)
  test_call([2, 4, 1, 2], :redistribute_at!, example_data, 2)

  test_call(5, :detect_loop, example_data)
  test_call({count: 5, data: [2, 4, 1, 2]}, :detect_infinite_loop_data, example_data)
  test_call(5042, :detect_loop, input_data)
end

part 2 do
  example_loop_at = detect_infinite_loop_data(example_data)[:data]
  test_call(4, :detect_loop, example_loop_at)

  input_loop_at = detect_infinite_loop_data(input_data)[:data]
  test_call(1086, :detect_loop, input_loop_at)
end
