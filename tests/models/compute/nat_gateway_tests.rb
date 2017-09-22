Shindo.tests("Fog::Compute[:aws] | nat_gateway", ['aws']) do
  @vpc = Fog::Compute[:aws].vpcs.create(:cidr_block => "10.0.10.0/24")
  @subnet = Fog::Compute[:aws].subnets.create(:vpc_id => @vpc.id, :cidr_block => "10.0.10.0/28", :availability_zone => 'us-east-1b')
  @ip = Fog::Compute[:aws].addresses.create(:domain => "vpc")

  model_tests(Fog::Compute[:aws].nat_gateways, {:allocation_id => @ip.allocation_id, :subnet_id => @subnet.identity}, true)

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
