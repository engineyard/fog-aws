module Fog
  module AWS
    class ECR
      class Repository < Fog::Model
        identity :name, :aliases         => 'repositoryName'

        attribute :arn, :aliases         => 'repositoryArn'
        attribute :uri, :aliases         => 'repositoryUri'
        attribute :created_at, :aliases  => 'createdAt'
        attribute :registry_id, :aliases => 'registryId'

        def save
          requires :name

          data = service.create_repository(name).body["repository"]
          merge_attributes(data)
        end

        def destroy(force=false, registry_id=nil)
          requires :name

          data = service.delete_repository(name, force, registry_id).body["repository"]
          merge_attributes(data)
        end
      end
    end
  end
end
