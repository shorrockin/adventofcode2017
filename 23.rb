require './boilerplate'

REGISTERS = "abcdefgh"
CURRENT_INSTRUCTION_REGISTER = :current_instruction
MUL_COUNT = :mul_count

def val(registers, arg)
  return (registers[arg] || 0) if REGISTERS.include?(arg)
  arg.to_i
end

COMMANDS = {
  :set => lambda do |registers, args|
    registers[args[0]] = val(registers, args[1])
  end,

  :mul => lambda do |registers, args|
    registers[args[0]] = val(registers, args[0]) * val(registers, args[1])
    registers[MUL_COUNT] ||= 0
    registers[MUL_COUNT] += 1
  end,

  :sub => lambda do |registers, args|
    registers[args[0]] = val(registers, args[0]) - val(registers, args[1])
  end,

  :jnz => lambda do |registers, args|
    if val(registers, args[0]) != 0
      registers[CURRENT_INSTRUCTION_REGISTER] = (registers[CURRENT_INSTRUCTION_REGISTER] + val(registers, args[1]) - 1)
    end
  end
}

Command = Struct.new(:name, :args)

class State
  include Loggable
  attr_accessor :registers, :commands
  def initialize(input, registers: {}, logging: false)
    @registers = registers
    @registers[CURRENT_INSTRUCTION_REGISTER] ||= 0
    @instructions = {}
    @logging = logging

    @commands = input.map do |line|
      command = line.split(" ")
      Command.new(command[0].to_sym, command[1..-1])
    end
    run
  end

  def run
    log "initailizing run procedure, #{@commands.length} commands"
    while @registers[CURRENT_INSTRUCTION_REGISTER] >= 0 && @registers[CURRENT_INSTRUCTION_REGISTER] < @commands.length
      command = @commands[@registers[CURRENT_INSTRUCTION_REGISTER] % @commands.length]
      log "command: #{command.name.to_s.blue}(#{command.args.map {|a| a.to_s.blue}.join(', ')}) (#{@registers[CURRENT_INSTRUCTION_REGISTER].to_s.yellow})"
      COMMANDS[command.name].call(@registers, command.args)
      log "registers:", pretty_registers
      @registers[CURRENT_INSTRUCTION_REGISTER] += 1
    end
  end

  def mul_count
    @registers[MUL_COUNT]
  end

  def register_at(register)
    @registers[register]
  end

  def pretty_registers
    ignore = @registers.reject {|k, v| [:mul_count, :current_instruction, 'a'].include?(k)}
    ignore.map {|k, v| "#{k}=>#{v}"}.join(', ')
  end
end

part 1 do
  log_call_on(State.new(input, logging: false), :mul_count)
end

part 2 do
  # registers = {'a' => 1, 'b'=>106500, 'c'=>123500, 'f'=>1, 'd'=>2, 'e'=>53250, 'g'=>53250, CURRENT_INSTRUCTION_REGISTER=>18}
  log_call_on(State.new(input, registers: {'a' => 1}, logging: true), :register_at, 'h')
end
