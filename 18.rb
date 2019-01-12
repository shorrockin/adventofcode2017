require './boilerplate'

LAST_SOUND_REGISTER = :last_sound
CURRENT_INSTRUCTION_REGISTER = :current_instruction
RECOVERY_REGISTER = :rcv_register
SND_QUEUE_REGISTER = :snd_queue_register
RCV_QUEUE_REGISTER = :rcv_queue_register
SND_COUNT_REGISTER = :snd_count

def val(registers, arg)
  return arg.to_i if (arg.to_i.to_s == arg)
  (registers[arg] || 0)
end

PART_ONE_COMMANDS = {
  :set => lambda {|registers, args| registers[args[0]] = val(registers, args[1]) },
  :add => lambda {|registers, args| registers[args[0]] = (registers[args[0]] || 0) + val(registers, args[1])},
  :mul => lambda {|registers, args| registers[args[0]] = (registers[args[0]] || 0) * val(registers, args[1])},
  :mod => lambda {|registers, args| registers[args[0]] = (registers[args[0]] || 0) % val(registers, args[1])},
  :jgz => lambda {|registers, args| registers[CURRENT_INSTRUCTION_REGISTER] = (registers[CURRENT_INSTRUCTION_REGISTER] + val(registers, args[1]) - 1) if val(registers, args[0]) > 0},
  :snd => lambda {|registers, args| registers[LAST_SOUND_REGISTER] = registers[args[0]]},
  :rcv => lambda {|registers, args| registers[RECOVERY_REGISTER] = registers[LAST_SOUND_REGISTER] if (registers[args[0]] || 0) != 0},
}

PART_TWO_COMMANDS = PART_ONE_COMMANDS.merge({
  :snd => lambda do |registers, args|
    registers[SND_QUEUE_REGISTER] << val(registers, args[0])
    registers[SND_COUNT_REGISTER] ||= 0
    registers[SND_COUNT_REGISTER] += 1
  end,

  :rcv => lambda do |registers, args|
    received = registers[RCV_QUEUE_REGISTER].delete_at(0)
    if received.nil?
      registers[CURRENT_INSTRUCTION_REGISTER] -= 1
    else
      # binding.pry
      registers[args[0]] = received
    end
  end
})

Command = Struct.new(:name, :args)

class State
  include Loggable
  attr_accessor :registers, :recovered_frequency, :definitions
  def initialize(input, definitions: PART_ONE_COMMANDS, registers: {}, run_to_completion: true, logging: false)
    @logging = logging
    @registers = registers
    @registers[CURRENT_INSTRUCTION_REGISTER] = 0
    @definitions = definitions

    @commands = input.map do |line|
      command = line.split(" ")
      Command.new(command[0].to_sym, command[1..-1])
    end

    run if run_to_completion
  end

  def run
    run_once while @registers[RECOVERY_REGISTER].nil?
    @recovered_frequency = @registers[RECOVERY_REGISTER]
  end

  def run_once
    command = @commands[@registers[CURRENT_INSTRUCTION_REGISTER] % @commands.length]
    @definitions[command.name].call(@registers, command.args)
    log "#{registers[:program] == "1" ? "1".red : "0".yellow}: executing command #{command.name.to_s.blue} with args #{command.args}. results: ", @registers
    @registers[CURRENT_INSTRUCTION_REGISTER] += 1
  end

  def blocking?
    command = @commands[@registers[CURRENT_INSTRUCTION_REGISTER] % @commands.length]
    (command.name == :rcv && @registers[RCV_QUEUE_REGISTER].length == 0)
  end
end

class DualState
  attr_accessor :s1 , :s2
  def initialize(input, logging: false)
    s1_queue = []
    s2_queue = []
    @s1 = State.new(input, definitions: PART_TWO_COMMANDS, logging: logging, run_to_completion: false, registers: {
      :program => "0",
      SND_QUEUE_REGISTER => s1_queue,
      RCV_QUEUE_REGISTER => s2_queue,
      "p" => 0,
    })


    @s2 = State.new(input, definitions: PART_TWO_COMMANDS, logging: logging, run_to_completion: false, registers: {
      :program => "1",
      SND_QUEUE_REGISTER => s2_queue,
      RCV_QUEUE_REGISTER => s1_queue,
      "p" => 1,
    })

    while !(@s1.blocking? && @s2.blocking?)
      @s1.run_once
      @s2.run_once
    end
  end

  def program_one_send_count
    @s2.registers[SND_COUNT_REGISTER]
  end
end

part 1 do
  state = State.new("""set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2""".split("\n"), logging: false)
  assert_equal(4, state.recovered_frequency, "example recovered frequency")

  state = State.new(input, logging: false)
  log_call_on(state, :recovered_frequency) # 3188
end

part 2 do
  state = DualState.new("""snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d""".split("\n"), logging: false)
  assert_call_on(state, 3, :program_one_send_count)

  state = DualState.new(input, logging: false)
  log_call_on(state, :program_one_send_count)

end
