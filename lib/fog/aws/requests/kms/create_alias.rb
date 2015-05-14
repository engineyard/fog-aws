module Fog
  module AWS
    class KMS
      class Real
        require 'fog/aws/parsers/kms/create_alias'

        def create_alias(name, key_id)
          request(
            'Action'      => 'CreateAlias',
            'AliasName'   => name,
            'TargetKeyId' => key_id,
          )
        end
      end

      class Mock
        def create_alias(name, key_id)
          response = Excon::Response.new

          if key_id.nil?
            raise ValidationError.new("KeyId must not be null")
          end

          if name.nil?
            raise ValidationError.new("AliasName must not be null")
          end

          unless name.starts_with?("alias/")
            raise ValidationError.new("Invalid identifier")
          end

          self.data[:keys][key_id] || raise(
            NotFound.new("Key '#{Fog::AWS::Mock.arn("kms", self.account_id, "key/#{key_id}", @region)}' does not exist")
          )

          self.data[:aliases][name] = {
            'AliasArn' => Fog::AWS::Mock.arn("kms", self.account_id, name, @region),
            'AliasName' => name,
            'TargetKeyId' => key_id,
          }

          response.body = {}
          response
        end
      end
    end
  end
end
