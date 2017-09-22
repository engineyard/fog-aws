module Fog
  module Compute
    class AWS
      class NatGateway < Fog::Model
        identity  :id,          :aliases => 'natGatewayId'

        attribute :address_set, :aliases => 'addressSet'
        attribute :create_time, :aliases => 'createTime'
        attribute :state
        attribute :subnet_id,   :aliases => 'subnetId'
        attribute :vpc_id,      :aliases => 'vpcId'

        attr_accessor :allocation_id

        def reload
          service.nat_gateways.get(self.identity)
        end

        def ready?
          state == 'available'
        end

        def address_set=(hash)
          self.attributes[:address_set] = service.addresses.all('allocation-id' => hash['allocationId'])
        end

        def destroy
          requires :id
          service.delete_nat_gateway(id)
          true
        end

        def save
          requires :subnet_id, :allocation_id
          merge_attributes(service.create_nat_gateway(subnet_id, allocation_id).body["natGatewaySet"].first)
        end
      end
    end
  end
end
