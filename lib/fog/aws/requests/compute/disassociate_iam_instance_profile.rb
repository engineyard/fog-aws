module Fog
  module Compute
    class AWS
      class Real
        require 'fog/aws/parsers/compute/disassociate_iam_instance_profile'

        # Associate an IAM Instance profile with an instance
        #
        # ==== Parameters
        # * association_id<~String> - Id of iam instance profile association
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
        # {Amazon API Reference}[https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DisassociateIamInstanceProfile.html]

        def disassociate_iam_instance_profile(association_id)
          request(
            'Action'        => 'DisassociateIamInstanceProfile',
            'AssociationId' => association_id,
            :parser         => Fog::Parsers::Compute::AWS::DisassociateIamInstanceProfile.new
          )
        end
      end

      class Mock
        def disassociate_iam_instance_profile(association_id)
          response = Excon::Response.new
          response.status = 200

          association = self.data[:instance_profile_associations][association_id]

          if association.nil?
            raise Fog::Compute::AWS::Error.new("InvalidParameterValue => Invalid value for associationId")
          end

          association['state'] = 'disassociating'

          response.body = {'iamInstanceProfileAssociation' => association, 'requestId' => Fog::AWS::Mock.request_id}
          response
        end
      end
    end
  end
end
