require 'pry'

def part_one(input, expect)
  nums = input.chars.map(&:to_i)
  sum = 0
  nums.each_with_index do |num, index|
    if num == nums[(index + 1) % nums.length]
      sum += num
    end
  end

  puts "\tSum: #{sum} (Expect: #{expect}) (Input: #{input})"
end

input = $<.first.strip

puts "Part 1"
part_one("1122", "3")
part_one("1111", "4")
part_one("1234", "0")
part_one("91212129", "9")
part_one("9122229", "15")
part_one(input, "?")

def part_two(input, expect)
  nums = input.chars.map(&:to_i)
  half = input.length / 2
  sum = 0
  nums.each_with_index do |num, index|
    if num == nums[(index + half) % nums.length]
      sum += num
    end
  end

  puts "\tSum: #{sum} (Expect: #{expect}) (Input: #{input})"
end

puts "Part Two"
part_two("1212", "6")
part_two("1221", "0")
part_two("123425", "4")
part_two("123123", "12")
part_two("12131415", "4")
part_two(input, "?")

puts "Done"
