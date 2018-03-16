#!/usr/bin/env ruby

class MegaGreeter
  attr_accessor :names

  # Create the object
  def initialize(names = "Mike")
    @names = names
  end

  def define_names
    if @names.nil?
      return "..."
    elsif @names.respond_to?("join")
    return @names.join(", ")
    else
      return @names
    end
  end

  # Say hi to everybody
  def say_hi
    puts "Hi " + define_names
  end

  # Say bye to everybody
  def say_bye
    puts "Bye " + define_names
  end
end


if __FILE__ == $0
  mg = MegaGreeter.new
  mg.say_hi
  mg.say_bye

  #Change name to be "Ihar"
  mg.names = "Ihar"
  mg.say_hi
  mg.say_bye

  # Change the name to an array of names
  mg.names = ["Albert", "Brenda", "Charles"]
  mg.say_hi
  mg.say_bye

  # Change to nil
  mg.names = nil
  mg.say_hi
  mg.say_bye
end
