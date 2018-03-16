#!/usr/bin/ruby

class Test
  
  def initialize(name="NA", sername="NA")
    @name = name
    @sername = sername
  end

  def output()
    for i in 0..10
      puts "Name#{i}: #@name, Sername#{i}: #@sername"
    end
  end
end

#Object creation
person1 = Test.new("Ihar", "Vauchok")
person2 = Test.new()

#Calling methods
person1.output()
person2.output()

