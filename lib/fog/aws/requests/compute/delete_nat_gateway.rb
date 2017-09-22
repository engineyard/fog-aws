module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/basic'
        #Deletes a Nat gateway from your AWS account
        #
        # ==== Parameters
        # * nat_gateway_id<~String> - The ID of the NatGateway you want to delete.
        #
        # === Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        # * 'requestId'<~String> - Id of request
        # * 'return'<~Boolean> - Returns true if the request succeeds.
        #
        # {Amazon API Reference}[http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-query-DeleteNatGateway.html]
        def delete_nat_gateway(nat_gateway_id)
          request(
            'Action' => 'DeleteNatGateway',
            'NatGatewayId' => nat_gateway_id,
            :parser => Fog::Parsers::Compute::AWS::Basic.new
          )
        end
      end

      class Mock
        def delete_nat_gateway(nat_gateway_id)
          Excon::Response.new.tap do |response|
            if nat_gateway_id
              response.status = 200
              self.data[:nat_gateways][nat_gateway_id][:deleted_at] = Time.now
              self.data[:nat_gateways][nat_gateway_id]['state'] = 'deleting'

              response.body = {
                'requestId' => Fog::AWS::Mock.request_id,
              }
            else
              message = 'MissingParameter => '
              message << 'The request must contain the parameter nat_gateway_id'
              raise Fog::Compute::AWS::Error.new(message)
            end
          end
        end
      end
    end
  end
end
