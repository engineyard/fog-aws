module Fog
  module AWS
    class ECR
      class Real
        # Delete repository
        # API Reference: https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_DeleteRepository.html
        # ==== Parameters
        # * name<~String> - Name of the repository to describe
        # * force<~Boolean> - Force deletion of the registry? (Required if the repository contains images)
        # * registry_id<~String> - The AWS account ID associated with the registry that contains the repositories to be described. If you do not specify a registry, the default registry is assumed.
        #
        # ==== Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        #   * repository<~Hash>:
        #     * createdAt<~Time> - When the repository was created
        #     * registoryId<~String> - AWS account ID associated with the registry
        #     * repositoryArn<~String> - ARN of the repository
        #     * repositoryName<~String> - Name of the repository
        #     * repositoryUri<~String> - URI of the repository

        def delete_repository(name, force=false, registry_id=nil)
          request(
            'Action'         => 'DeleteRepository',
            'force'          => force,
            'registryId'     => registry_id,
            'repositoryName' => name,
          )
        end
      end

      class Mock
        def delete_repository(name, force=false, registry_id=nil)
          response   = Excon::Response.new
          repository = self.data[:repositories][name]

          if repository.nil?
            raise Fog::AWS::ECR::NotFound.new("The repository with name '#{name}' does not exist in the registry with id '#{self.owner_id}'")
          end

          self.data[:repositories].delete(name)

          response.body = {"repository" => repository}
          response
        end
      end
    end
  end
end
