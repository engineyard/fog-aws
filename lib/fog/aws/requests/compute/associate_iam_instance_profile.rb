module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/associate_iam_instance_profile'

        # Associate an IAM Instance profile with an instance
        #
        # ==== Parameters
        # * instance_id<~String> - Id of instance to associate address with
        # * instance_profile_name <~String> - Name of the instance profile
        #
        # ==== Returns
        # * response<~Excon::Response>:
        #   * body<~Hash>:
        #     * 'requestId'<~String> - Id of request
        #     * 'iamInstanceProfileAssociation'<~Hash>
        #       * 'associationId'<~String> - ID of the association
        #       * 'iamInstanceProfile'<~Hash>
        #         * 'arn'<~String> - Arn of the instance profile
        #         * 'id'<~String> - ID of the instance profile
        #       * 'instanceId'<~String> - ID of the instance
        #       * 'state'<~String> - State of the association process
        #     * 'associationId'<~String> - association Id for the attachment
        #
        # {Amazon API Reference}[https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_AssociateIamInstanceProfile.html]

        def associate_iam_instance_profile(instance_id, instance_profile_name)
          request(
            'Action'                  => 'AssociateIamInstanceProfile',
            'IamInstanceProfile.Name' => instance_profile_name,
            'InstanceId'              => instance_id,
            :parser                   => Fog::Parsers::Compute::AWS::AssociateIamInstanceProfile.new
          )
        end
      end

      class Mock
        def associate_iam_instance_profile(instance_id, instance_profile_name)
          response        = Excon::Response.new
          response.status = 200
          association_id  = Fog::AWS::Mock.instance_profile_association_id

          result = {
            "iamInstanceProfile" => {
              "arn" => "arn:aws:iam::#{self.data[:owner_id]}:instance-profile/#{instance_profile_name}",
              "id" => Fog::Mock.random_hex(24).upcase
            },
            "associationId" => association_id,
            "instanceId"    => instance_id,
            "state"         => "associating"
          }

          self.data[:instance_profile_associations][association_id] = result

          response.body = {'iamInstanceProfileAssociation' => result, 'requestId' => Fog::AWS::Mock.request_id}
          response
        end
      end
    end
  end
end
