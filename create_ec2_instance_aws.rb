#!/usr/bin/ruby

require 'aws-sdk-ec2'
require 'base64'
require 'aws-sdk-elasticloadbalancing'

az = 'us-east-1a'
vpc_net = '172.31.0.0/16'
sub_net = '172.31.16.0/20'
key = 'test'

ec2 = Aws::EC2::Resource.new(region: 'us-east-1')

def tag(method, name)
  method.create_tags({ tags: [{ key: 'Name', value: name }]})
end

#Creating an Amazon EC2 VPC
vpc = ec2.create_vpc({ cidr_block: vpc_net })
vpc.modify_attribute({ enable_dns_support: { value: true }})
vpc.modify_attribute({ enable_dns_hostnames: { value: true }})
tag(vpc, 'MyVPC')

#Creating an Internet Gateway and Attaching It to a VPC in Amazon EC2
igw = ec2.create_internet_gateway
igw.attach_to_vpc(vpc_id: vpc.vpc_id)
tag(igw, 'MyIGW')

#Creating a Public Subnet for Amazon EC2
subnet = ec2.create_subnet({
  vpc_id: vpc.vpc_id,
  cidr_block: sub_net,
  availability_zone: az
})
tag(subnet, 'MySubnet')

#Creating an Amazon EC2 Route Table and Associating It with a Subnet
table = ec2.create_route_table({ vpc_id: vpc.vpc_id })
tag(table, 'MyRouteTable')
table.create_route({
  destination_cidr_block: '0.0.0.0/0',
  gateway_id: igw.id
})
table.associate_with_subnet({ subnet_id: subnet.id })

#Creating an Amazon EC2 Security Group
sg = ec2.create_security_group({
  group_name: 'MySecurityGroup',
  description: 'Security group for MyInstance',
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

#Creating an Amazon EC2 Instance
script = '#!/bin/bash -xe
mkdir /tmp/Test'

encoded_script = Base64.encode64(script)

count = Integer ARGV[0]
while count > 0
  instance = ec2.create_instances({
    image_id: 'ami-1853ac65',
    min_count: 1,
    max_count: 1,
    key_name: key,
    user_data: encoded_script,
    instance_type: 't2.micro',
    placement: { availability_zone: az },
    network_interfaces: [{
      device_index: 0,
      subnet_id: subnet.id,
      groups: [sg.id],
      delete_on_termination: true,
      associate_public_ip_address: true}]
  })
  
#Wait for the instance to be created, running, and passed status checks
ec2.client.wait_until(:instance_status_ok, {instance_ids: [instance.first.id]})
tag(instance, "MyInstance#{count}")
count -= 1
end

#Creating ELB
elb = Aws::ElasticLoadBalancing::Client.new(region: 'us-east-1')
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

#Registering ec2 instances to ELB
ec2.instances.each do |instance|
  if instance.state.name == "running"
    elb.register_instances_with_load_balancer({
      instances: [{ instance_id: "#{instance.id}"}],
      load_balancer_name: "MyLoadBalancer"
    })
  end
end
