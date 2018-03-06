module Fog
  module Parsers
    module Compute
      module AWS
        class DescribeIamInstanceProfileAssociations < Fog::Parsers::Base
          def reset
            @attachment = {'iamInstanceProfile' => {}}
            @response = {'iamInstanceProfileAssociations' => []}
          end

          def start_element(name, attrs=[])
            super
            case name
            when 'iamInstanceProfileAssociationSet'
              @in_instance_profile_associations = true
            when 'iamInstanceProfile'
              @in_instance_profile = true
            end
          end

          def end_element(name)
            if @in_instance_profile
              case name
              when 'arn', 'id'
                @attachment['iamInstanceProfile'][name] = value
              when 'iamInstanceProfile'
                @in_instance_profile = false
              end
            elsif @in_instance_profile_associations
              case name
              when 'associationId', 'instanceId', 'state'
                @attachment[name] = value
              when 'item'
                @response['iamInstanceProfileAssociations'] << @attachment
                @attachment = {'iamInstanceProfile' => {}}
              end
            else
              case name
              when 'requestId'
                @response[name] = value
              end
            end
          end
        end
      end
    end
  end
end
