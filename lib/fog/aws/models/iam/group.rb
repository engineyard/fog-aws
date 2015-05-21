module Fog
  module AWS
    class IAM
      class Group < Fog::Model

        identity :id, aliases: 'GroupId'

        attribute :arn,  aliases: 'Arn'
        attribute :name, aliases: 'GroupName'
        attribute :path, aliases: 'Path'

        def save
          requires :name

          merge_attributes(
            service.create_group(self.name, self.path).body["Group"]
          )
        end
      end
    end
  end
end
