module Fog
  module Parsers
    module Compute
      module AWS
        class ReplaceRouteTableAssociation < Fog::Parsers::Base
          def reset
            @response = {}
          end

          def end_element(name)
            @response[name] = value
          end
        end
      end
    end
  end
end
