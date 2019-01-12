require './boilerplate'

Port = Struct.new(:left, :right, :left_used, :right_used, :connected_to) do
  def self.from_str(line)
    parts = line.split("/")
    Port.new(parts[0].to_i, parts[1].to_i, false, false, nil)
  end

  def join(to, using_port)
    connect_from_left = (left == using_port && !left_used)
    connect_to_left = (to.left == using_port && !to.left_used)

    from = Port.new(
      left,
      right,
      left_used || connect_from_left,
      right_used || !connect_from_left,
      connected_to
    )

    Port.new(
      to.left,
      to.right,
      to.left_used || connect_to_left,
      to.right_used || !connect_to_left,
      from
    )
  end

  def to_s
    return "#{left}/#{right}" if connected_to.nil?
    connected_to.to_s+"--"+left.to_s+"/"+right.to_s
  end


  def can_use?(port)
    (left == port && !left_used) ||
      (right == port && !right_used)
  end

  def unused
    case [left_used, right_used]
    when [true, true] then []
    when [true, false] then [right]
    when [false, true] then [left]
    else; [left, right]; end
  end

  def length; connected_to.nil? ? 1 : connected_to.length + 1; end
  def can_start?; can_use?(0); end
  def connection_strength; connected_to.nil? ? strength : strength + connected_to.connection_strength; end
  def strength; left + right; end
  def can_join?(to, using_port); can_use?(using_port) && to.can_use?(using_port); end
  def as_starting_port; Port.new(left, right, left == 0, right == 0, nil); end
end

EXAMPLE_PORTS = """0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10""".split("\n").map {|line| Port.from_str(line)}

INPUT_PORTS = input.map {|line| Port.from_str(line)}

class State
  include Loggable
  attr_accessor :ports, :connections
  def initialize(ports, logging: false)
    @logging = logging
    @ports = ports
  end

  def starting_ports
    @ports.select(&:can_start?)
  end

  def strongest_connection
    connections.map(&:connection_strength).max
  end

  def longest_connection_strength
    connections
      .group_by(&:length)
      .map {|length, conns| [length, conns]}
      .sort
      .last
      .last
      .map(&:connection_strength)
      .max
  end

  def connections
    @connections ||= starting_ports.map do |port|
      connections_from(port.as_starting_port, @ports - [port])
    end.flatten
  end

  def connections_from(port, remaining_ports)
    raise "from port should only have 1 used port" unless !port.left_used || !port.right_used

    candidates = [port]

    remaining_ports.each do |remaining_port|
      remaining_port.unused.each do |port_num|
        if port.can_join?(remaining_port, port_num)
          candidates += connections_from(
            port.join(remaining_port, port_num),
            remaining_ports - [remaining_port]
          )
        end
      end
    end

    candidates
  end
end

part "1/2" do
  assert_call_on(EXAMPLE_PORTS[0], 2, :strength)
  assert_call_on(EXAMPLE_PORTS[0], 1, :length)
  assert_call_on(EXAMPLE_PORTS[0], true, :can_join?, EXAMPLE_PORTS[1], 2)
  assert_call_on(EXAMPLE_PORTS[0], false, :can_join?, EXAMPLE_PORTS[1], 0)
  assert_call_on(EXAMPLE_PORTS[0].join(EXAMPLE_PORTS[1], 2), 6, :connection_strength)
  assert_call_on(EXAMPLE_PORTS[0].join(EXAMPLE_PORTS[1], 2), 2, :length)

  state = State.new(EXAMPLE_PORTS)
  assert_call_on(state, 31, :strongest_connection)
  assert_call_on(state, 19, :longest_connection_strength)

  state = State.new(INPUT_PORTS)
  log_call_on(state, :strongest_connection)
  log_call_on(state, :longest_connection_strength)
end
