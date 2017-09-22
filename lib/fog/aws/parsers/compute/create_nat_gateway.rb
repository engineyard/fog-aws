module Fog
  module Parsers
    module Compute
      module AWS
        class CreateNatGateway < Fog::Parsers::Base
          def reset
            @nat_gateway = { 'addressSet' => {} }
            @response = { 'natGatewaySet' => [] }
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'natGatewayAddressSet'
              @in_address_set = true
            when 'item'
              @in_item = true
            end
          end

          def end_element(name)
            if @in_address_set
              case name
              when 'allocationId'
                @nat_gateway['addressSet'][name] = value
              when 'item'
                @in_address_set = false
              end
            else
              case name
              when 'createTime'
                @nat_gateway[name] = Time.parse(value)
              when 'natGatewayId', 'state', 'subnetId', 'vpcId'
                @nat_gateway[name] = value
              when 'natGateway'
                @response['natGatewaySet'] << @nat_gateway
                @nat_gateway = { 'addressSet' => {} }
              when 'requestId'
                @response[name] = value
              end
            end
          end
        end
      end
    end
  end
end
