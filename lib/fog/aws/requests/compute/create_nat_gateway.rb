module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/create_nat_gateway'

        # Creates a NatGateway
        # ==== Parameters
        # * AllocationId - The allocation ID of the EIP to associate with the gateway
        # * SubnetId     - The subnet in which to create the NAT gateway
        # * options<~Hash>
        #   * ClientToken  - Client supplied token to ensure idempotency
        #
        # {Amazon API Reference}[http://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateNatGateway.html]

        def create_nat_gateway(subnet_id, allocation_id, options={})
          request({
            'Action'       => 'CreateNatGateway',
            'SubnetId'     => subnet_id,
            'AllocationId' => allocation_id,
            :parser        => Fog::Parsers::Compute::AWS::CreateNatGateway.new
          })
        end
      end

      class Mock
        def create_nat_gateway(subnet_id, allocation_id, options={})
          response       = Excon::Response.new
          nat_gateway_id = Fog::AWS::Mock.nat_gateway_id
          subnet         = self.data[:subnets].detect { |s| s['subnetId'] == subnet_id }
          raise Fog::Compute::AWS::Error.new("InvalidSubnet => Subnet #{subnet_id} was not found") unless subnet
          nat_gateway    = {
            'addressSet'   => {'allocationId'=> allocation_id},
            'createTime'   => Time.now,
            'natGatewayId' => nat_gateway_id,
            'state'        => 'pending',
            'subnetId'     => subnet_id,
            'vpcId'        => subnet['vpcId']
          }

          self.data[:nat_gateways][nat_gateway_id] = nat_gateway

          response.body = {
            'requestId' => Fog::AWS::Mock.request_id,
            'natGatewaySet' => [nat_gateway]
          }
          response
        end
      end
    end
  end
end
