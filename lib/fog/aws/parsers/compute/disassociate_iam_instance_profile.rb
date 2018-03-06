module Fog
  module Parsers
    module Compute
      module AWS
        class DisassociateIamInstanceProfile < Fog::Parsers::Base
          def reset
            @response = {'iamInstanceProfileAssociation' => {'iamInstanceProfile' => {}}}
          end

          def start_element(name, attrs=[])
            super
            case name
            when 'iamInstanceProfileAssociation'
              @in_instance_profile_association = true
            when 'iamInstanceProfile'
              @in_instance_profile = true
            end
          end

          def end_element(name)
            if @in_instance_profile
              case name
              when 'arn', 'id'
                @response['iamInstanceProfileAssociation']['iamInstanceProfile'][name] = value
              when 'iamInstanceProfile'
                @in_instance_profile = false
              end
            elsif @in_instance_profile_association
              case name
              when 'associationId', 'instanceId', 'state'
                @response['iamInstanceProfileAssociation'][name] = value
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
