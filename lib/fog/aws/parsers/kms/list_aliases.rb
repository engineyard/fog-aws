module Fog
  module Parsers
    module AWS
      module KMS
        class ListAliases < Fog::Parsers::Base
          def reset
            @response = { 'Aliases' => [] }
          end

          def start_element(name, attrs = [])
            super
            case name
            when 'Aliases'
              @aliass = []
            when 'member'
              @alias = {}
            end
          end

          def end_element(name)
            case name
            when 'AliasName', 'AliasArn', 'TargetKeyId'
              @alias[name] = value
            when 'Truncated'
              @response['Truncated'] = (value == 'true')
            when 'NextMarker'
              @response['Marker'] = value
            end
          end
        end
      end
    end
  end
end
