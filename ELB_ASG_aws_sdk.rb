#!/usr/bin/ruby

require 'aws-sdk-ec2'
require 'base64'
require 'aws-sdk-elasticloadbalancing'
require 'aws-sdk-autoscaling'

img = 'ami-1853ac65'
region = 'us-east-1'
azone = 'us-east-1a'
key = 'test'
itype = 't2.micro'
vpc_net = '172.31.0.0/16'
sub_net = '172.31.16.0/20'

ec2 = Aws::EC2::Resource.new(region: region)

def tag(method, name)
  method.create_tags({ tags: [{ key: 'Name', value: name }]})
end

#Creating an Amazon EC2 VPC
vpc = ec2.create_vpc({ 
  cidr_block: vpc_net
})
vpc.modify_attribute({ 
  enable_dns_support: { 
    value: true 
  }
})
vpc.modify_attribute({ 
  enable_dns_hostnames: { 
    value: true 
  }
})
tag(vpc, 'MyVPC')

#Creating an Internet Gateway and Attaching It to a VPC in Amazon EC2
igw = ec2.create_internet_gateway
igw.attach_to_vpc(vpc_id: vpc.vpc_id)
tag(igw, 'MyIGW')

#Creating a Public Subnet for Amazon EC2
subnet = ec2.create_subnet({
  vpc_id: vpc.vpc_id,
  cidr_block: sub_net,
  availability_zone: azone
})
tag(subnet, 'MySubnet')

#Creating an Amazon EC2 Route Table and Associating It with a Subnet
table = ec2.create_route_table({ 
  vpc_id: vpc.vpc_id 
})
tag(table, 'MyRouteTable')
table.create_route({
  destination_cidr_block: '0.0.0.0/0',
  gateway_id: igw.id
})
table.associate_with_subnet({ 
  subnet_id: subnet.id 
})

#Creating an Amazon EC2 Security Group
sg = ec2.create_security_group({
  group_name: 'MySecurityGroup',
  description: 'Security group for ELB, ASG',
  vpc_id: vpc.vpc_id
})
sg.authorize_ingress({
  ip_permissions: [{
    ip_protocol: 'tcp',
    from_port: 22,
    to_port: 22,
    ip_ranges: [{
      cidr_ip: '0.0.0.0/0'
    }]
  },
  {
    ip_protocol: 'tcp',
    from_port: 80,
    to_port: 80,
    ip_ranges: [{
      cidr_ip: '0.0.0.0/0'
    }]
  }]
})
tag(sg, 'MySecurityGroup')

#Creating ELB
elb = Aws::ElasticLoadBalancing::Client.new(region: region)
elb.create_load_balancer({
  listeners: [
    {
      instance_port: 80,
      instance_protocol: "HTTP",
      load_balancer_port: 80,
      protocol: "HTTP",
    },
  ],
  load_balancer_name: "MyLoadBalancer",
  security_groups: [sg.id],
  subnets: [subnet.id],
})

#Creating an Amazon EC2 Instance
script = '#!/bin/bash -xe
yum -y install httpd php
chkconfig httpd on
/etc/init.d/httpd start
cd /var/www/html
echo "Instance 1" > index.html'

encoded_script = Base64.encode64(script)

#Creating ASG
asg = Aws::AutoScaling::Client.new(region: region)
asg.create_launch_configuration({
  launch_configuration_name: "MyLaunchConfig",
  image_id: img,
  key_name: key,
  security_groups: [sg.id],
  user_data: encoded_script,
  instance_type: itype,
  associate_public_ip_address: true
})

asg.create_auto_scaling_group({
  auto_scaling_group_name: "MyAutoScalingGroup",
  launch_configuration_name: "MyLaunchConfig",
  min_size: 2,
  max_size: 3,
  desired_capacity: 2,
  default_cooldown: 1,
  availability_zones: [azone],
  load_balancer_names: ["MyLoadBalancer"],
  health_check_type: "ELB",
  health_check_grace_period: 120,
  vpc_zone_identifier: subnet.id,
})
