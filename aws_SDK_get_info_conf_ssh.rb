#!/usr/bin/ruby

require 'aws-sdk-ec2'

#define variables
home = "/root"
regions = Array.new
hosts_list = Array.new

#searching and saving information about aws regions from ~/.aws/config
File.open("#{home}/.aws/config").each { |line| regions << line[9..-2] if line.match("region") }

#searching and saving information about ec2 instances from aws
for r in regions
  ec2 = Aws::EC2::Resource.new(region: "#{r}")
  ec2.instances.each do |instance|
    if instance.state.name == "running"
      hosts_list << instance.public_dns_name
      instance.tags.each { |tag| hosts_list << tag.value if tag.key == "Name" }
      hosts_list << instance.key_name
    end
  end
end

#save information about ec2 instances to ~/.ssh/config
i = 0
while i <= hosts_list.size()/2
  out_file = File.new("#{home}/.ssh/config", "a")
  out_file.puts("Host #{hosts_list[i+1]}
    HostName #{hosts_list[i]}
    User ec2-user
    IdentityFile #{home}/.ssh/#{hosts_list[i+2]}.pem
  ")
  out_file.close
  i += 3
end
