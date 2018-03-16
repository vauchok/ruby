#!/opt/puppetlabs/puppet/bin/ruby

require 'aws-sdk-ec2'

home = "/root"
regions = Array.new
hosts_list = Array.new

File.open("#{home}/.aws/config").each do |line|
  if line.match("region")
    regions << line[9..-2]
  end
end

for r in regions
  ec2 = Aws::EC2::Resource.new(region: "#{r}")
  ec2.instances.each do |instance|
    if instance.state.name == "running"
      hosts_list << instance.public_dns_name
      instance.tags.each do |tag|
        if tag.key == "Name"
          hosts_list << tag.value
        end
      end
    end
  end
end

i = 0
while i <= hosts_list.size()/2
  out_file = File.new("#{home}/.ssh/config", "a")
  out_file.puts("Host #{hosts_list[i+1]}
    HostName #{hosts_list[i]}
    User ec2-user
    IdentityFile #{home}/.ssh/#{hosts_list[i]}.pem
  ")
  out_file.close
  i += 2
end
