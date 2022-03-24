require 'pry-byebug'

secret = [2, 4, 3, 2]
input = [1, 2, 2, 4]

dupl = []
binding.pry
input.each_with_index do |element, index|
  indices = secret.each_index.select { |e| secret[e] == element }
  if indices.include?(index)
    puts "The #{element}(#{index}) is present in that index"
  elsif indices.empty?
    puts "The #{element}(#{index}) is not present"
  elsif dupl.include?(element) == false
    puts "The #{element}(#{index}) is present but not in that index"
    dupl.push(element)
  end
end
