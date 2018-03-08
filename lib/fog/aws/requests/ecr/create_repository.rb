module Fog
  module AWS
    class ECR
      class Real
        # Delete repository
        # API Reference: https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_DeleteRepository.html
        # ==== Parameters
        # * name<~String> - Name of the repository to describe
        #
        # ==== Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        #   * repository<~Hash>:
        #     * createdAt<~Time> - When the repository was created
        #     * registryId<~String> - AWS account ID associated with the registry
        #     * repositoryArn<~String> - ARN of the repository
        #     * repositoryName<~String> - Name of the repository
        #     * repositoryUri<~String> - URI of the repository

        def create_repository(name)
          request(
            'Action' => 'CreateRepository',
            'repositoryName' => name
          )
        end
      end

      class Mock
        def create_repository(name)
          response   = Excon::Response.new
          repository = {
            'repositoryName' => name,
            'repositoryUri'  => "#{self.owner_id}.dkr.ecr.us-east-1.amazonaws.com/#{name}",
            'repositoryArn'  => "arn:aws:ecr:#{self.region}:#{self.owner_id}:repository/#{name}",
            'createdAt'      => Time.now.to_f,
            'registryId'     => self.owner_id
          }

          if self.data[:repositories][name]
            raise Fog::AWS::ECR::Error.new("RepositoryAlreadyExistsException => The repository with name 'test' already exists in the registry with id '#{self.owner_id}'")
          else
            self.data[:repositories][name] = repository
          end

          response.body = {"repository" => repository}
          response
        end
      end
    end
  end
end
