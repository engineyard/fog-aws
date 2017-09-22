module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/describe_nat_gateways'

        # Describe all or specified nat_gateways
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # === Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        # * 'requestId'<~String> - Id of request
        # * 'NatGatewaySet'<~Array>:
        #   * 'natGatewayId'<~String> - The ID of the Internet gateway.
        #   * 'attachmentSet'<~Array>: - A list of VPCs attached to the Internet gateway
        #     * 'subnetId'<~String> - The ID of the VPC the Internet gateway is attached to
        #     * 'state'<~String> - The current state of the attachment
        # * 'tagSet'<~Array>: Tags assigned to the resource.
        #   * 'key'<~String> - Tag's key
        #   * 'value'<~String> - Tag's value
        #
        # {Amazon API Reference}[http://docs.amazonwebservices.com/AWSEC2/latest/APIReference/ApiReference-ItemType-NatGatewayType.html]
        def describe_nat_gateways(filters = {})
          unless filters.is_a?(Hash)
            Fog::Logger.warning("describe_nat_gateways with #{filters.class} param is deprecated, use nat_gateways('nat-gateway-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'nat-gateway-id' => [*filters]}
          end
          params = Fog::AWS.indexed_filters(filters)
          request({
            'Action' => 'DescribeNatGateways',
            :idempotent => true,
            :parser => Fog::Parsers::Compute::AWS::DescribeNatGateways.new
          }.merge!(params))
        end
      end

      class Mock
        def describe_nat_gateways(filters = {})
          nat_gateways = self.data[:nat_gateways].values

          if filters['nat-gateway-id']
            nat_gateways = nat_gateways.reject {|nat_gateway| nat_gateway['natGatewayId'] != filters['nat-gateway-id']}
          end

          nat_gateways.each do |gateway|
            gateway['addressSet'].merge!(
              'networkInterfaceId' => Fog::AWS::Mock.network_interface_id,
              'privateIp' => Fog::AWS::Mock.ip_address
            ) unless gateway['addressSet'].keys.include?('privateIp')
            case gateway['state']
            when 'pending'
              if Time.now - gateway['createTime'] >= Fog::Mock.delay
                if address = self.data[:addresses].values.detect { |a| a['allocationId'] == a['addressSet']['allocationId'] }
                  gateway['state'] = 'available'
                else
                  gateway['state'] = 'failed'
                end
              end
            when 'deleting'
              if Time.now - gateway[:deleted_at] >= Fog::Mock.delay
                gateway['state'] = 'deleted'
              end
            end
          end

          Excon::Response.new(
            :status => 200,
            :body   => {
              'requestId'     => Fog::AWS::Mock.request_id,
              'natGatewaySet' => nat_gateways
            }
          )
        end
      end
    end
  end
end
