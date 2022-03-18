require 'colorize'
require 'pry-byebug'

module Assist
  def color_background(number)
    case number
    when '  1  '
      return number.colorize(:background => :blue)
    when '  2  '
      return number.colorize(:background => :yellow)
    when '  3  '
      return number.colorize(:background => :green)
    when '  4  '
      return number.colorize(:background => :magenta)
    when '  5  '
      return number.colorize(:background => :cyan)
    when '  6  '
      return number.colorize(:background => :black)
    else
      puts 'error'
    end
  end

  def set_color(arr)
    display = ""
    arr.each do |element|
      display += color_background("  #{element}  ")
    end
    display
  end
  
  def numeric?(char)
    char.match?(/[[:digit:]]/)
  end

  def compare(arr1, arr2)
    arr1.each_with_index do |element, index|
      if arr1[index] != arr2[index]
        return false
      end
    end
    true
  end
end

# We generate and access the secret code here
class CodeMaker
  attr_accessor :secret_code

  def initialize
    @secret_code = Array.new
  end

  def generate_code
    4.times do
      @secret_code.push(1 + rand(6))
    end
  end
end

# We play the game here
class Board
  include Assist

  def display_code(arr)
    puts set_color(arr)
  end

  def get_input(secret)
    loop do
      puts 'Please enter 4 numbers between 1 and 6 (without spaces)'
      @input = gets.chomp
      if (numeric?(@input) == true && @input.length == 4) && (@input.split('').all? { |element| element.to_i.positive? && element.to_i < 7 })
        @input = @input.split('')
        puts set_color(@input)
        break
      else
        puts 'Wrong input'
      end
    end
    return check_win(@input, secret)
  end

  def check_win(arr1, arr2)
    if compare(arr1, arr2)
      puts 'Congrats, you won!'
      true
    else
      puts 'Wrong guess'
      false
    end
  end
end

class Player
  attr_accessor :input

  def initialize
  end
end

yo = CodeMaker.new
jugador = Player.new
board = Board.new
yo.generate_code
secret = yo.secret_code
board.display_code(secret)
loop do
  if board.get_input(secret)
    break
  end
end
