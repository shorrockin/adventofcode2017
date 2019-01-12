require 'pry'
require '../advent2018/utils'
include Utils

part 1 do
  def count_steps(instructions)
    steps = 0
    position = 0

    while !instructions[position].nil?
      steps += 1
      previous_position = position
      position += instructions[position]
      instructions[previous_position] += 1
    end

    return steps
  end

  def test_one(input, expected)
    test(count_steps(input.dup), expected, input)
  end

  test_one([0, 3, 0, 1, -3], 5)
  test_one(input.map(&:to_i), nil)
end

part 2 do
  def previous_value(number)
    if number >= 2
      number + 1
    else
      number - 1
    end
  end

  def possible_exits(instructions)
    exits = []

    instructions.each_with_index do |inst, index|
      if previous_value(inst) + index >= instructions.length
        exits << index
      end
    end

    exits
  end

  def count_steps(instructions)
    steps = 0
    position = 0

    while !instructions[position].nil?
      steps += 1
      previous_position = position
      position += instructions[position]

      if instructions[previous_position] >= 3
        instructions[previous_position] -= 1
      else
        instructions[previous_position] += 1
      end

      # p({steps: steps, position: position, instructions: instructions})
    end

    return steps
  end

  def test_two(input, expected)
    test(count_steps(input.dup), expected, input)
  end

  test(previous_value(0), -1, 0) # -1 changes to 0
  test(previous_value(1), 0, 1) # 0 changes to 1
  test(previous_value(2), 3, 2) # 3 changes to 2
  test(previous_value(3), 4, 3) # 4 changes to 3
  test(previous_value(4), 5, 4) # 3 changes to 2
  test(previous_value(5), 6, 5) # 4 changes to 3

  test(possible_exits([2, 3, 2, 3, 2]), [1, 2, 3, 4], [2, 3, 2, 3, 0])
  test(possible_exits([2, 3, 2, 3, -1]), [1, 2, 3], [2, 3, 2, 3, -1])
  test_two([2, 3, 2, 3, -1], 10)

  test(possible_exits(input.map(&:to_i)), nil, "possible_exits(input)")
  test_two(input.map(&:to_i), nil)
end
