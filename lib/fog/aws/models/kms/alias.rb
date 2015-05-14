module Fog
  module AWS
    class KMS
      class Alias < Fog::Model
        identity :name, :aliases => 'AliasName'

        attribute :arn,    :aliases => 'KeyArn'
        attribute :key_id, :aliases => 'TargetKeyId'

        def save
          requires :name, :key_id

          service.create_alias(name, key_id)

          true
        end
      end
    end
  end
end
