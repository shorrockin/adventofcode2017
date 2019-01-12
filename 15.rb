require './boilerplate'

class Generator
  attr_accessor :initial, :factor, :last, :divisible

  def initialize(initial, factor, divisible = 1)
    @initial = initial
    @last = initial
    @factor = factor
    @divisible = divisible
  end

  def generate_next
    loop do
      @last = @last * @factor
      @last = @last % 2147483647
      break if (@last % @divisible == 0)
    end
    return @last.to_s(2).rjust(16, '0').chars.last(16).join
  end
end

def count_matches(gen1, gen2, iterations = 40_000_000)
  matches = 0
  iterations.times do |iter|
    val_1 = gen1.generate_next
    val_2 = gen2.generate_next
    if val_1 == val_2
      matches += 1
      puts "#{iter} found match"
    end
  end
  matches
end

part "1 (example)" do
  # gen1 = Generator.new(1092455, 16807)
  # gen2 = Generator.new(430625591, 48271)
  # assert_call(588, :count_matches, gen1, gen2)
end

part "1" do
  # gen1 = Generator.new(512, 16807)
  # gen2 = Generator.new(191, 48271)
  # log_call(:count_matches, gen1, gen2)
end

part "2 (example)" do
  # gen1 = Generator.new(1092455, 16807, 4)
  # gen2 = Generator.new(430625591, 48271, 8)
  # assert_call(309, :count_matches, gen1, gen2, 5_000_000)
end

part "2" do
  gen1 = Generator.new(512, 16807, 4)
  gen2 = Generator.new(191, 48271, 8)
  log_call(:count_matches, gen1, gen2, 5_000_000)
end
