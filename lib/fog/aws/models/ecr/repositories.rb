require 'fog/aws/models/ecr/repository'

module Fog
  module AWS
    class ECR
      class Repositories < Fog::Collection
        model Fog::AWS::ECR::Repository

        def all(params={})
          load(service.describe_repositories(params).body["repositories"])
        end

        def get(name)
          all('repositoryNames' => [name]).first
        rescue
        end
      end
    end
  end
end
