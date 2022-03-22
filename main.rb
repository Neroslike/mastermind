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

  # White clues: Select the indices of the element present in secret array, then checks if the current index is present.
  # No clue: Means the indices array is empty, therefore no input from the user is present at the secret array.
  # Red clue: Same process as the white clue, but if the array isn't empty it means the element is present but
  # not at that index. To prevent cluttering it saves a copy of the element in a duplicate array so it can give
  # a single red clue per repeated element.
  def find_differences(input, secret)
    input.map!(&:to_i)
    clues = []
    dupl = []
    display = ""
    input.each_with_index do |element, index|
      indices = secret.each_index.select { |e| secret[e] == element }
      if indices.include?(index)
        clues.push("●".colorize(:white))
      elsif indices.empty?
        next
      elsif dupl.include?(element) == false
        clues.push("●".colorize(:red))
        dupl.push(element)
      end
    end
    clues.sort! {|a, b| b <=> a }
    clues.each do |clue|
      display += "#{clue}  "
    end
    display
  end

  # Set the numbers (strings) colors
  def set_color(arr)
    display = ""
    arr.each do |element|
      display += color_background("  #{element}  ") + " "
    end
    display
  end

  # Checks if a (string) number is numeric
  def numeric?(char)
    char.match?(/[[:digit:]]/)
  end

  # Compare two arrays to check if they are the same
  def compare(arr1, arr2)
    arr1.map! { |element| element.to_i }
    arr1.each_with_index do |element, index|
      if element != arr2[index]
        return false
      end
    end
    true
  end
end

# Initialize the secret code
class CodeMaker
  attr_accessor :secret_code

  def initialize
    @secret_code = Array.new
  end

  # Generates a new, random code for the game
  def generate_code
    4.times do
      @secret_code.push(rand(1..6))
    end
  end
end

# Logic to display the code and check the win condition
class Board
  include Assist

  # Displays the coloured code
  def display_code(arr)
    puts set_color(arr)
  end

  # Gets valid input from the player and compares it to the secret code
  def get_input(secret)
    loop do
      puts 'Please enter 4 numbers between 1 and 6 (without spaces)'
      @input = gets.chomp
      if (numeric?(@input) == true && @input.length == 4) && (@input.split('').all? { |element| element.to_i.positive? && element.to_i < 7 })
        @input = @input.split('')
        puts "#{set_color(@input)} #{find_differences(@input, secret)}"
        break
      else
        puts 'Wrong input'
      end
    end
    check_win(@input, secret)
  end

  # Calls #compare method to check win condition
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

yo = CodeMaker.new
board = Board.new
yo.generate_code
secret = yo.secret_code
turns = 0
loop do
  turns += 1
  puts "You have #{12 - turns} turns left"
  if board.get_input(secret)
    break
  elsif turns == 12
    puts 'Game over, the code was:'
    board.display_code(secret)
    break
  end
end
