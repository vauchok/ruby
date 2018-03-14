#!/usr/bin/env ruby

puts "Please enter the array lenght (min=3, max=20):"
l = Integer gets.chomp!

if l >= 3 && l <= 20
  m = ((1..999).to_a.sample l).join(", ")
  puts m.select.with_index { |_, index| index.even? } + a.select.with_index { |_, index| index.odd? }
else
  puts "The array lenght (min=3, max=20):"
end
