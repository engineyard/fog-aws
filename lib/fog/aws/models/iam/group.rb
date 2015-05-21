module Fog
  module AWS
    class IAM
      class Group < Fog::Model

        identity :id, aliases: 'GroupId'

        attribute :arn,  aliases: 'Arn'
        attribute :name, aliases: 'GroupName'
        attribute :path, aliases: 'Path'

        def add_user(username)
          requires :name

          service.add_user_to_group(self.name, username)
        end

        def attach(policy_arn)
          requires :name

          service.attach_group_policy(self.name, policy_arn)
        end

        def save
          if !persisted?
            requires :name

            merge_attributes(
              service.create_group(self.name, self.path).body["Group"]
            )
          else
            params = {}

            if self.name
              params['NewGroupName'] = self.name
            end

            if self.path
              params['NewPath'] = self.path
            end

            service.update_group(self.name, params)
            true
          end
        end

        def policies
          requires :name

          service.policies(group_name: self.name)
        end

        def reload
          requires :name

          data = begin
                   collection.get(self.name)
                 rescue Excon::Errors::SocketError
                   nil
                 end

          return unless data

          merge_attributes(data.attributes)
          self
        end
      end
    end
  end
end
