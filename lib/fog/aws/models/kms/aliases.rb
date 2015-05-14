require 'fog/aws/models/kms/alias'

module Fog
  module AWS
    class KMS
      class Aliases < Fog::PagedCollection
        attribute :filters
        attribute :truncated

        model Fog::AWS::KMS::Alias

        def initialize(attributes)
          self.filters ||= {}
          super
        end

        # This method deliberately returns only a single page of results
        def all(filters_arg = filters)
          filters.merge!(filters_arg)

          result = service.list_aliases(filters).body

          filters[:marker] = result['Marker']
          self.truncated = result['Truncated']

          load(result['Aliases'])
        end
      end
    end
  end
end
