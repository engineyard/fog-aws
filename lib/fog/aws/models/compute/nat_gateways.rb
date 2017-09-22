require 'fog/aws/models/compute/nat_gateway'

module Fog
  module Compute
    class AWS
      class NatGateways < Fog::Collection
        attribute :filters

        model Fog::Compute::AWS::NatGateway
        def initialize(attributes)
          self.filters ||= {}
          super
        end

        def all(filters_arg = filters)
          unless filters_arg.is_a?(Hash)
            Fog::Logger.warning("all with #{filters_arg.class} param is deprecated, use all('nat-gateway-id' => []) instead [light_black](#{caller.first})[/]")
            filters_arg = {'nat-gateway-id' => [*filters_arg]}
          end
          filters = filters_arg
          data = service.describe_nat_gateways(filters).body
          load(data['natGatewaySet'])
        end

        def get(nat_gateway_id)
          if nat_gateway_id
            self.class.new(:service => service).all('nat-gateway-id' => nat_gateway_id).first
          end
        end
      end
    end
  end
end
