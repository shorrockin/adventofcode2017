require './boilerplate'

INPUT_PATTERN = /(\w+) \((\d+)\)( -> (.*))?/

example_input = """pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)"""

class Disc
  attr_accessor :name, :weight, :above_names, :children, :parent
  def initialize(line)
    @name = line[1]
    @weight = line[2].to_i
    @above_names = []
    @above_names = line[4].split(", ").map(&:strip) unless line[3].nil?
    @children = []
    @parent = nil
  end

  def assign_parent(parent)
    @parent = parent
    @parent.children << self
  end

  def actual_weight
    weight + @children.map(&:actual_weight).sum
  end

  def balanced?
    @children.map(&:actual_weight).flatten.uniq.length <= 1
  end

  def log_children
    @children.map {|c| [c.name, c.actual_weight]}.to_h
  end
end

def parse(lines)
  lines.map do |l|
    d = Disc.new(INPUT_PATTERN.match(l))
    [d.name, d]
  end.to_h
end

def process(input)
  input.each do |_, d|
    d.above_names.each do |name|
      input[name].assign_parent(d)
    end
  end
end

def root(input)
  point = input.first[1]
  while point.parent; point = point.parent; end
  point.name
end

example_input = parse(example_input.split("\n"))
process(example_input)

part 1 do
  assert_equal(13, example_input.length, "example_input.length")
  assert_equal(57, example_input['xhth'].weight, "example_input[1].weight")
  assert_equal("xhth", example_input['xhth'].name, "example_input[1].name")
  assert_equal(["ktlj", "cntj", "xhth"], example_input['fwft'].above_names, "example_input[5].above_names")
  assert_equal("tknk", root(example_input), "root(example_input)")

  unbalanced = example_input.values.reject(&:balanced?)
  assert_equal(1, unbalanced.length, "example_input.unabalanced.length")
  log_call_on(unbalanced.first, :log_children)

  parsed = parse(input)
  process(parsed)
  log_call(:root, parsed)

  # 2090 - too high (was actual weight, not actual weight - sum(children weight)
  unbalanced = parsed.values.reject(&:balanced?)
  unbalanced.each do |disk|
    log_call_on(disk, :log_children)
  end
end

part 2 do

end
