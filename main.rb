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
    clues = Hash.new(0)
    dupl = []
    input.each_with_index do |element, index|
      indices = secret.each_index.select { |e| secret[e] == element }
      if indices.include?(index)
        if input.tally.fetch(element, 0) >= secret.tally.fetch(element, 0) && input.tally.fetch(element, 0) > 1
          clues[:white] += 1
          clues[:red] -= 1
        else
          clues[:white] += 1
        end
      elsif indices.empty?
        next
      elsif dupl.include?(element) == false && input.tally.fetch(element, 0) >= secret.tally.fetch(element, 0)
        clues[:red] += secret.tally.fetch(element, 0)
        dupl.push(element)
      elsif dupl.include?(element) == false && input.tally.fetch(element, 0) < secret.tally.fetch(element, 0)
        clues[:red] += input.tally.fetch(element, 0)
      end
    end
    clues[:red] = 0 if clues[:red].positive? == false
    clues
  end

  def display_clues(clues)
    display = ""
    display = ["●".colorize(:white)] * clues[:white] * '  '
    if display.empty? && clues[:red].positive?
      display += ["●".colorize(:red)] * clues[:red] * '  '
    elsif clues[:red].positive?
      display += '  ' + ["●".colorize(:red)] * clues[:red] * '  '
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
  include Assist
  attr_accessor :secret_code

  def initialize
    @secret_code = Array.new
  end

  # Generates a new, random code for the game
  def generate_code_computer
    4.times do
      @secret_code.push(rand(1..6))
    end
  end

  def generate_code_player
    loop do
      puts 'Please enter 4 numbers between 1 and 6 (without spaces)'
      @secret_code = gets.chomp
      if (numeric?(@secret_code) == true && @secret_code.length == 4) && (@secret_code.split('').all? { |element| element.to_i.positive? && element.to_i < 7 })
        @secret_code = @secret_code.split('')
        @secret_code.map!(&:to_i)
        break
      else
        puts 'Wrong input'
      end
    end
  end

  def test
    @secret_code = [2, 1, 3, 3]
  end
end

# Logic to display the code and check the win condition
class Board
  include Assist

  attr_accessor :current_clues

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
        puts "#{set_color(@input)} #{display_clues(find_differences(@input, secret))}"
        break
      else
        puts 'Wrong input'
      end
    end
    check_win(@input, secret)
  end

  def get_input_computer(input, secret)
    @input = input
    puts "#{set_color(@input)} #{display_clues(find_differences(@input, secret))}"
    @current_clues = find_differences(@input, secret)
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

  def initialize
    @perm = [1, 2, 3, 4, 5, 6].repeated_permutation(4).to_a.sort
  end

  def algo(guess)
    @perm.select! { |e| find_differences(guess, e) == @current_clues}
    next_guess = @perm[rand(0..@perm.length - 1)]
    next_guess
  end
end

loop do
  puts 'Do you wanna be the CODEBREAKER or the CODEMAKER'
  puts '1. CODEBREAKER'
  puts '2. CODEMAKER'
  gamemode = gets.chomp
  if gamemode == '1'
    computer = CodeMaker.new
    board = Board.new
    computer.test
    secret = computer.secret_code
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
  elsif gamemode == '2'
    player = CodeMaker.new
    board = Board.new
    player.generate_code_player
    secret = player.secret_code
    turns = 0
    input = [1, 1, 2, 2]
    loop do
      turns += 1
      sleep 1
      puts "Computer turn ##{turns}"
      if board.get_input_computer(input, secret)
        break
      end
      input = board.algo(input)
    end
  else
    puts "Wrong input"
  end
end

