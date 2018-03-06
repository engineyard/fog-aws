module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/describe_iam_instance_profile_associations'

        # Describe all or specified instance profile associations
        #
        # ==== Parameters
        # * filters<~Hash> - List of filters to limit results with
        #
        # === Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        # * 'requestId'<~String> - Id of request
        # * 'iamInstanceProfileAssociations'<~Array>:
        #   * 'associationId'<String> - ID of the association
        #   * 'iamInstanceProfile'<~Hash>:
        #     * 'arn'<~String> - ARN of the instance profile
        #     * 'id'<~String> - ID of the instance profile
        #   * 'instanceId'<~String> - ID of the instance that the profile is associated with
        #   * 'state'<~String> - State of the association
        #
        # {Amazon API Reference}[https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeIamInstanceProfileAssociations.html]

        def describe_iam_instance_profile_associations(filters = {})
          unless filters.is_a?(Hash)
            Fog::Logger.warning("describe_iam_instance_profile_associations with #{filters.class} param is deprecated, use describe_iam_instance_profile_associations('instance-id' => []) instead [light_black](#{caller.first})[/]")
            filters = {'instance-id' => [*filters]}
          end
          params = Fog::AWS.indexed_filters(filters)
          request({
            'Action' => 'DescribeIamInstanceProfileAssociations',
            :idempotent => true,
            :parser => Fog::Parsers::Compute::AWS::DescribeIamInstanceProfileAssociations.new
          }.merge!(params))
        end
      end

      class Mock
        def describe_iam_instance_profile_associations(filters = {})
          response = Excon::Response.new
          response.status = 200
          associations = self.data[:instance_profile_associations].values

          if instance_id = filters['instance-id']
            associations.select! { |hash| hash["instanceId"] == instance_id }
          end

          if state = filters["state"]
            associations.select! { |hash| hash["state"] == 'state' }
          end

          associations.each do |assoc|
            case assoc['state']
            when 'associating'
              assoc['state'] = 'associated'
            when 'disassociating'
              assoc['state'] = 'disassociated'
            end
          end

          response.body = {'iamInstanceProfileAssociations' => associations, 'requestId' => Fog::AWS::Mock.request_id}
          response
        end
      end
    end
  end
end
