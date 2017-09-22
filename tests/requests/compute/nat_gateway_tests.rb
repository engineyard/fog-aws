Shindo.tests('Fog::Compute[:aws] | nat_gateway requests', ['aws']) do
  NAT_GATEWAY_FORMAT = {
    'addressSet' => {
      'allocationId'       => String,
      'networkInterfaceId' => Fog::Nullable::String,
      'privateIp'          => Fog::Nullable::String,
      'publicIp'           => Fog::Nullable::String,
    },
    'createTime'   => Fog::Time,
    'natGatewayId' => String,
    'state'        => String,
    'subnetId'     => String,
    'vpcId'        => String
  }

  NAT_GATEWAY_RESPONSE = {
    'natGatewaySet' => [NAT_GATEWAY_FORMAT],
    'requestId'     => String
  }

  @vpc = Fog::Compute[:aws].vpcs.create(:cidr_block => "10.0.10.0/24")
  @subnet = Fog::Compute[:aws].subnets.create(:vpc_id => @vpc.id, :cidr_block => "10.0.10.0/28", :availability_zone => 'us-east-1b')
  @ip = Fog::Compute[:aws].addresses.create(:domain => "vpc")

  tests('success') do
    tests("#create_nat_gateway('#{@subnet.identity}', '#{@ip.allocation_id}')").formats(NAT_GATEWAY_RESPONSE) do
      data = Fog::Compute[:aws].create_nat_gateway(@subnet.identity, @ip.allocation_id).body
      @nat_gateway_id = data['natGatewaySet'].first['natGatewayId']
      data
    end

    tests("#delete_nat_gateway('#{@nat_gateway_id}')").formats(AWS::Compute::Formats::BASIC) do
      Fog::Compute[:aws].delete_nat_gateway(@nat_gateway_id).body
    end
  end

  @ip.destroy
  begin
    @subnet.destroy
  rescue => e
    if e.message.match(/DependencyViolation/)
      sleep 5
      retry
    else
      raise e
    end
  end
  @vpc.destroy
end
