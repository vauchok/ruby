#!/usr/bin/ruby

home = "/root"
regions = Array.new
hosts_list = Array.new

File.open("#{home}/.aws/config").each do |line|
  if line.match("region")
    regions << line[9..-2]
  end
end

for i in regions
    hosts_list.concat(`aws ec2 describe-instances --region #{i} --query 'Reservations[*].Instances[*].[PublicDnsName,Tags[?Key==\`Name\`].Value]' --filters "Name=instance-state-name,Values=running"`.split("\"").grep(/^[\w]/))
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
