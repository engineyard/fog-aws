module Fog
  module AWS
    class ECR < Fog::Service
      requires :aws_access_key_id, :aws_secret_access_key
      recognizes :region, :host, :path, :port, :scheme, :persistent, :version, :instrumentor, :instrumentor_name

      request_path 'fog/aws/requests/ecr'

      request :create_repository
      request :describe_repositories
      request :delete_repository

      model_path 'fog/aws/models/ecr'
      model :repository
      collection :repositories

      class Real
        attr_reader :region

        include Fog::AWS::CredentialFetcher::ConnectionMethods

        def initialize(options={})
          @instrumentor = options[:instrumentor]
          @instrumentor_name = options[:instrumentor_name] || 'fog.aws.ecr'
          @connection_options = options[:connection_options] || {}

          @region     = options[:region]     || 'us-east-1'
          @host       = options[:host]       || "ecr.#{@region}.amazonaws.com"
          @path       = options[:path]       || "/"
          @persistent = options[:persistent] || false
          @scheme     = options[:scheme]     || 'https'
          @version    = options[:version]    || '20150921'
          @connection = Fog::XML::Connection.new("#{@scheme}://#{@host}:#{@port}#{@path}", @persistent, @connection_options)

          setup_credentials(options)
        end

        def reload
          @connection.reset
        end

        private

        def setup_credentials(options)
          @aws_access_key_id      = options[:aws_access_key_id]
          @aws_secret_access_key  = options[:aws_secret_access_key]
          @aws_session_token     = options[:aws_session_token]
          @aws_credentials_expire_at = options[:aws_credentials_expire_at]

          @signer = Fog::AWS::SignatureV4.new( @aws_access_key_id, @aws_secret_access_key,@region,'ecr')
        end

        def request(body)
          params = {}
          target = "AmazonEC2ContainerRegistry_V#{@version}.#{body.delete('Action')}"
          refresh_credentials_if_expired

          params.merge!(
            :body => Fog::JSON.encode(body),
            :expects => 200,
            :method => :post,
            :path => '/'
          )

          date = Fog::Time.now
          params[:headers] = {
            'Date' => date.to_date_header,
            'Host' => @host,
            'X-Amz-Date' => date.to_iso8601_basic,
            'X-Amz-Target' => target,
            'Content-Type' => 'application/x-amz-json-1.1',
            'Content-Length' => params[:body].bytesize.to_s,
          }.merge!(params[:headers] || {})
          params[:headers]['x-amz-security-token'] = @aws_session_token if @aws_session_token
          params[:headers]['Authorization'] = @signer.sign(params, date)

          if @instrumentor
            @instrumentor.instrument("#{@instrumentor_name}.request", params) do
              _request(params)
            end
          else
            _request(params)
          end
        end

        def _request(params)
          response = @connection.request(params)

          unless response.body.empty?
            response.body = Fog::JSON.decode(response.body)
          end

          response
        rescue Excon::Errors::HTTPStatusError => error
          match = Fog::AWS::Errors.match_error(error)
          raise if match.empty?
          if %w(RepositoryNotFoundException).include?(match[:code])
            raise Fog::AWS::ECR::NotFound.slurp(error, match[:message])
          else raise(Fog::AWS::ECR::Error.slurp(error, "#{match[:code]} => #{match[:message]}"))
          end
        end
      end

      class Mock
        attr_reader :region

        include Fog::AWS::CredentialFetcher::ConnectionMethods

        def self.data
          @data ||= Hash.new do |hash, region|
            hash[region] = Hash.new do |region_hash, key|
              region_hash[key] = {
                :repositories => {}
              }
            end
          end
        end

        def self.reset
          @data = nil
        end

        def data
          self.class.data[@region][@aws_access_key_id]
        end

        def reset
          self.class.reset
        end

        def owner_id
          @owner_id ||= Fog::AWS::Mock.owner_id
        end

        def initialize(options={})
          @region                = options[:region] || "us-east-1"
          @aws_access_key_id     = options[:aws_access_key_id]
          @aws_secret_access_key = options[:aws_secret_access_key]
        end
      end
    end
  end
end
