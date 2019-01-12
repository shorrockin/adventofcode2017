require './boilerplate'

def process(iterations, cycle_inc, part = :one)
  array = [0]
  current = 0

  iterations.times do |cycle|
    current = ((current + cycle_inc) % (cycle + 1)) + 1
    array.insert(current, cycle + 1) if (current == 1 || part == :one)
  end

  case part
  when :one then array[(current + 1) % array.length]
  when :two then array[1]
  end
end

part 1 do
  assert_call(638, :process, 2017, 3)
  log_call(:process, 2017, 344)
end

part 2 do
  log_call(:process, 50_000_000, 344, :two)
end
