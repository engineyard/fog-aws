module Fog
  module Parsers
    module Compute
      module AWS
        class DescribeNatGateways < Fog::Parsers::Base
          def reset
            @nat_gateway = { 'addressSet' => {} }
            @response = { 'natGatewaySet' => [] }
            @tag = {}
            @attachment = {}
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'natGatewayAddressSet'
              @in_nat_gateway_address_set = true
            end
          end

          def end_element(name)
            if @in_nat_gateway_address_set
              case name
              when 'item'
                @in_nat_gateway_address_set = false
              else
                @nat_gateway['addressSet'][name] = value
              end
            else
              case name
              when 'natGatewayId', 'state', 'subnetId', 'vpcId'
                @nat_gateway[name] = value
              when 'item'
                @response['natGatewaySet'] << @nat_gateway
                @nat_gateway = { 'addressSet' => {} }
              when 'requestId'
                @response[name] = value
              when 'createTime'
                @nat_gateway[name] = Time.parse(value)
              end
            end
          end
        end
      end
    end
  end
end
