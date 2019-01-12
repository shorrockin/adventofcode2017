require 'pry'
require '../advent2018/utils'

def part_one(rows, expect)
  sum = rows.reduce(0) do |accum, row|
    values = row.split("\t").map(&:to_i).sort
    accum + (values.last - values.first)
  end

  Utils.display(sum, expect, rows)
end

Utils.part(1) do
  part_one(["5\t1\t9\t5", "7\t5\t3", "2\t4\t6\t8"], 18)
  part_one(Utils.input, nil)
end

def part_two(rows, expect)
  sum = rows.reduce(0) do |accum, row|
    values = row.split("\t").map(&:to_f).sort.reverse
    div_result = nil

    values.each_with_index do |value, starting_index|
      (starting_index+1...values.length).each do |index|
        result = value / values[index]
        if result.to_i == result
          div_result = result
          break
        end
      end
    end
    accum + div_result
  end

  Utils.display(sum.to_i, expect, rows)
end

Utils.part(2) do
  part_two(["5\t9\t2\t8", "9\t4\t7\t3", "3\t8\t6\t5"], 9)
  part_two(Utils.input, nil)
end
