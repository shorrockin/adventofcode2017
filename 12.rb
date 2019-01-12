require './boilerplate'

INPUT_PATTERN = /(\d+) <-> (.*)/

class State
  include Loggable
  attr_accessor :connections
  def initialize(input, logging: true)
    @logging = logging
    @connections = {}

    input.each do |line|
      match = INPUT_PATTERN.match(line)
      source = match[1].to_i
      destination = match[2].split(',').map(&:to_i)
      connect!(source, destination)
      destination.each {|d| connect!(d, source)}
      log 'creating connection between', source, destination
    end
  end

  private def connect!(from, to)
    to = [to] unless to.is_a?(Array)
    @connections[from] ||= []
    @connections[from] = (@connections[from] + to).uniq.sort
  end

  def num_connected_to(source); connected_to(source).length; end
  def num_groups; groups.length; end

  def connected_to(source)
    unprocessed = [source]
    processed = []
    all_connections = []

    while unprocessed.any?
      current = unprocessed.pop
      processed << current

      current_conn = (@connections[current] || [])
      current_unprocessed = (current_conn - processed)

      unprocessed += current_unprocessed
      all_connections = (all_connections + current_conn).uniq
    end

    all_connections
  end

  def groups
    unprocessed = @connections.keys
    out = {}

    while unprocessed.any?
      current = unprocessed.pop
      current_conn = connected_to(current)
      out[current] = current_conn
      unprocessed -= current_conn
    end

    out
  end
end

part "1/2" do
  example_input = """0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5""".split("\n")

  state = State.new(example_input, logging: false)
  connections = state.connections
  assert_call_on(connections, 7, :length)
  assert_call_on(state, 6, :num_connected_to, 0)
  assert_call_on(state, 2, :num_groups)

  state = State.new(input, logging: false)
  log_call_on(state, :num_connected_to, 0)
  log_call_on(state, :num_groups)
end
