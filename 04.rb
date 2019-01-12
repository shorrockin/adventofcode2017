require 'pry'
require '../advent2018/utils'

include Utils

def is_valid?(input)
  words = input.split(" ")

  words.each_with_index do |word, index|
    return false if words[index+1..words.length].include?(word)
  end

  true
end

def is_anagram?(left, right)
  left.chars.sort == right.chars.sort
end

def is_valid_anagram?(input)
  words =  input.split(" ")

  words.each_with_index do |word, index|
    words[index+1..words.length].each do |remaining|
      return false if is_anagram?(word, remaining)
    end
  end

  true
end

def test_one(input, expected)
  test(is_valid?(input), expected, input)
end

def test_two(input, expected)
  test(is_valid_anagram?(input), expected, input)
end

part 1 do
  test_one("aa bb cc dd ee", true)
  test_one("aa bb cc dd aa", false)
  test_one("aa bb cc dd aaa", true)
  test(input.count {|passphrase| is_valid?(passphrase)}, nil, "[input]")
end

part 2 do
  test_two("abcde fghij", true)
  test_two("abcde xyz ecdab", false)
  test_two("a ab abc abd abf abj", true)
  test_two("iiii oiii ooii oooi oooo", true)
  test_two("oiii ioii iioi iiio", false)
  test(input.count {|passphrase| is_valid_anagram?(passphrase)}, nil, "[input]")
end
