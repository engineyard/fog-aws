module Fog
  module AWS
    class KMS
      class Real
        require 'fog/aws/parsers/kms/list_aliases'

        def list_aliases(options={})
          params = {}

          if options[:marker]
            params['Marker'] = options[:marker]
          end

          if options[:limit]
            params['Limit'] = options[:limit]
          end

          request({
            'Action' => 'ListAliases',
            :parser  => Fog::Parsers::AWS::KMS::ListAliases.new
          }.merge(params))
        end
      end

      class Mock
        def list_aliases(options={})
          limit  = options[:limit]
          marker = options[:marker]

          if limit
            if limit > 1_000
              raise Fog::AWS::KMS::Error.new(
                "ValidationError => 1 validation error detected: Value '#{limit}' at 'limit' failed to satisfy constraint: Member must have value less than or equal to 1000"
              )
            elsif limit <  1
              raise Fog::AWS::KMS::Error.new(
                "ValidationError => 1 validation error detected: Value '#{limit}' at 'limit' failed to satisfy constraint: Member must have value greater than or equal to 1"
              )
            end
          end

          alias_set = if marker
                        self.data[:markers][marker] || []
                      else
                        self.data[:aliases].values
                      end

          aliases = if limit
                      alias_set.slice!(0, limit)
                    else
                      alias_set
                    end

          truncated = aliases.size < alias_set.size

          marker = truncated && "metadata/l/#{account_id}/#{UUID.uuid}"

          response = Excon::Response.new

          body = {
            'Aliases'   => aliases,
            'Truncated' => truncated,
            'RequestId' => Fog::AWS::Mock.request_id
          }

          if marker
            self.data[:markers][marker] = alias_set
            body.merge!('Marker' => marker)
          end

          response.body = body
          response.status = 200

          response
        end
      end
    end
  end
end
