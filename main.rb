#!/usr/bin/ruby

$value = "I'm a global variable"
class Customer
  @@number_of_customers = 0
  Value = "I'm a constant"
  def initialize(id, name, addr)
    @customer_id = id
    @customer_name = name
    @customer_addr = addr
  end
  def display_details()
    puts "Customer id #@customer_id\nCustomer name #@customer_name\nCustomer address #@customer_addr\n#{Value}\n"
  end
  def total_no_of_customers()
    @@number_of_customers += 1
    puts "Total number of customers: #@@number_of_customers"
    puts $value
  end
end

# Create Objects
c1 = Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
c2 = Customer.new("2", "Poul", "New Empire road, Khandala")

# Call methods
c1.display_details()
c1.total_no_of_customers()
c2.display_details()
c2.total_no_of_customers()
puts $value
