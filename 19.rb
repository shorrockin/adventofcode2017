require './boilerplate'

EXAMPLE_MAP = """
     |
     |  +--+
     A  |  C
 F---|----E|--+
     |  |  |  D
     +B-+  +--+
""".split("\n").reject {|l| l.strip.length == 0}

class State < Boilerstate
  attr_accessor :letters, :steps
  def parse(input)
    velocity = [1, 0]
    position = [0, input[0].index("|")]
    done     = false
    @letters = []
    @steps   = 0

    while !done
      @steps  += 1
      next_row = position[0] + velocity[0]
      next_col = position[1] + velocity[1]

      break unless valid?(input, next_row, next_col)

      position = [next_row, next_col]
      icon     = input[position[0]][position[1]]

      log "moving to #{next_row}/#{next_col}, icon '#{icon}' with velocity: #{velocity}" do
        case icon
        when "|" then log "continuing to move, encountered '|'"
        when "-" then log "continuing to move, encountered '-'"
        when "+"
          log "hit corner, need to adjust velocity, current #{velocity}"
          velocity = [velocity[0].abs ^ 1, velocity[1].abs ^ 1]

          if !valid?(input, position[0] + velocity[0], position[1] + velocity[1])
            velocity = [velocity[0] * -1, velocity[1] * -1]
            log "inverting velocity"
          end

          log "new velocity #{velocity}"
        when " "
          log "found empty space, marking done"
          done = true
        else
          log "found letter, appending '#{icon}'"
          @letters << icon
        end
      end
    end
  end

  def joined_letters; @letters.join; end

  def valid?(input, row, col)
    return false if row < 0
    return false if row >= input.length
    return false if col < 0
    return false if col >= input[row].length
    return false if input[row][col] == " "
    true
  end
end

part "1/2" do
  assert_call_on(State.new(EXAMPLE_MAP, logging: false), "ABCDEF", :joined_letters)
  assert_call_on(State.new(EXAMPLE_MAP, logging: false), 38, :steps)
  log_call_on(State.new(input), :joined_letters)
  log_call_on(State.new(input), :steps)
end
