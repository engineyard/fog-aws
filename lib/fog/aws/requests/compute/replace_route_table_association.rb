module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/replace_route_table_association'

        # Replaces a route table association
        #
        # ==== Parameters
        # * association_id - The current association ID to replace
        # * route_table_id - ID of the new route table
        #
        # === Returns
        # * response<~Excon::Response>
        # * body<~Hash>:
        # * 'requestId'<~String> - ID of the request
        # * 'newAssociationId'<~String> - New association ID
        def replace_route_table_association(association_id, route_table_id)
          request(
            'Action' => 'ReplaceRouteTableAssociation',
            'AssociationId' => association_id,
            'RouteTableId' => route_table_id,
            :parser => Fog::Parsers::Compute::AWS::ReplaceRouteTableAssociation.new
          )
        end
      end

      class Mock
        def replace_route_table_association(association_id, route_table_id)
          old_route_table = self.data[:route_tables].detect { |rt| rt['associationSet'].any? { |a| a['routeTableAssociationId'] == association_id } }
          new_route_table = self.data[:route_tables].detect { |rt| rt['routeTableId'] == route_table_id }
          new_assoc_id    = "rtbassoc-#{Fog::Mock.random_hex(8)}"

          binding.pry
          association = old_route_table['associationSet'].delete_if { |a| a['routeTableAssociationId'] == association_id }
          association.merge!('routeTableId' => route_table_id, 'routeTableAssociationId' => new_assoc_id)
          new_route_table['associationSet'].push(association)

          response = Excon::Response.new
          response.body = {'requestId' => Fog::AWS::Mock.request_id, 'newAssociationId' => new_assoc_id}
          response
        end
      end
    end
  end
end
