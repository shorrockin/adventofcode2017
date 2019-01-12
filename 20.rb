require './boilerplate'

VELOCITY_REGEX=/v=<([^,]*),([^,]*),([^,]*)>/
POSITION_REGEX=/p=<([^,]*),([^,]*),([^,]*)>/
ACCELERATION_REGEX=/a=<([^,]*),([^,]*),([^,]*)>/
STABILITY_ROUNDS = 1000

EXAMPLE_INPUT = """p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>
p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>
p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>""".split("\n")

Coordinate = Struct.new(:x, :y, :z) do
  def +(coord); Coordinate.new(x + coord.x, y + coord.y, z + coord.z); end
  def to_a; [x, y, z]; end
  def distance(coord); (x - coord.x).abs + (y - coord.y).abs + (z - coord.z).abs; end
end

ZERO_POSITION = Coordinate.new(0, 0, 0)

class Particle
  attr_accessor :id, :position, :velocity, :acceleration
  def initialize(id, line)
    @id           = id
    @position     = parse_coord(POSITION_REGEX, line)
    @velocity     = parse_coord(VELOCITY_REGEX, line)
    @acceleration = parse_coord(ACCELERATION_REGEX, line)
  end

  def tick
    @velocity = @velocity + @acceleration
    @position = @position + @velocity
  end

  def distance(from)
    @position.distance(from)
  end

  def to_s
    "Particle<#{@id}>(p=#{@position.to_a}, v=#{@velocity.to_a}, a=#{@acceleration.to_a})"
  end

  private def parse_coord(regex, line)
    match = regex.match(line)
    Coordinate.new(match[1].to_i, match[2].to_i, match[3].to_i)
  end
end

class State < Boilerstate
  attr_accessor :particles
  def parse(input)
    log "starting parsing of #{input.length} particles" do
      particles = input.each_with_index.map {|line, index| Particle.new(index, line)}
      last_sort = nil
      stability = 0
      cycles = 0

      log "initial state" do
        particles.each {|p| log(p.to_s)}
      end

      # run it until the sort order is stable
      while stability < STABILITY_ROUNDS && particles.length > 1
        log "cycle #{cycles}" do
          particles.each(&:tick)
          particles.each {|p| log(p.to_s)}

          particles = particles
            .group_by {|p| p.position.to_a}
            .select {|k, v| v.length == 1 }
            .map {|k, v| v.first} if @options[:collisions]

          log "particles remaining after collisions", particles.length

          if (stability + 1) == STABILITY_ROUNDS
            sorted = particles.sort_by {|p| p.distance(ZERO_POSITION)}.map(&:id)
            stability = 0 if sorted != last_sort
            log "resetting stability" if sorted != last_sort
            last_sort = sorted
          end

          cycles += 1
          stability += 1

          log "stability at", stability
        end
      end

      @particles = particles
    end
  end
end

part 2 do
  state = State.new(EXAMPLE_INPUT, collisions: true, logging: false)
  assert_call_on(state.particles, 1, :length)

  state = State.new(input, collisions: true, logging: false)
  log_call_on(state.particles, :length)
end


part 1 do
  particle = Particle.new(0, "p=< 3,0,0>, v=< 2,4,0>, a=<-1,0,0>")
  assert_call_on(particle, Coordinate.new(3, 0, 0), :position)
  assert_call_on(particle, Coordinate.new(2, 4, 0), :velocity)
  assert_call_on(particle, Coordinate.new(-1, 0, 0), :acceleration)

  state = State.new(input)
  log_call_on(state.particles.sort_by {|p| p.distance(ZERO_POSITION) }.first, :id)
end
