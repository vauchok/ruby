#!/opt/puppetlabs/puppet/bin/ruby

require 'aws-sdk-ec2'

ec2 = Aws::EC2::Resource.new(region: "us-east-1")
ec2.instances.each do |i|
  if i.state.name == "running"
    puts "The architecture of the image: #{i.architecture}"
    puts "The IAM instance profile: #{i.iam_instance_profile}"
    puts "ID: #{i.id}"
    puts "The instance type: #{i.instance_type}"
    puts "The name of the key pair: #{i.key_name}"
    puts "The time the instance was launched: #{i.launch_time}"
    puts "The private DNS: #{i.private_dns_name}"
    puts "The private IPv4: #{i.private_ip_address}"
    puts "The public DNS: #{i.public_dns_name}"
    puts "The public IPv4: #{i.public_ip_address}"
    puts "The device name: #{i.root_device_name}"
    puts "The root device type: #{i.root_device_type}"
    puts "Security group:\n"
    i.security_groups.each do |sg|
      puts "name: #{sg.group_name}\tid: #{sg.group_id}"
    end
    puts "The current state: #{i.state.name}"
    puts "The ID of the subnet: #{i.subnet_id}"
    puts "The ID of the VPC: #{i.vpc_id}"
    puts "The tag:\n"
    i.tags.each do |tag|
      puts "key: #{tag.key}\tvalue: #{tag.value}"
    end
  end
end
