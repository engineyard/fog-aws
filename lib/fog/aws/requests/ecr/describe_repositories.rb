module Fog
  module AWS
    class ECR
      class Real
        # Describe repositoies
        # API Reference: https://docs.aws.amazon.com/AmazonECR/latest/APIReference/API_DescribeRepositories.html
        # ==== Parameters
        # * maxResults<~Integer> - Number of results to return per page
        # * nextToken<~String> - Previous nextToken value for paginated results
        # * registryId<~String> - The AWS account ID associated with the registry that contains the repositories to be described. If you do not specify a registry, the default registry is assumed.
        # * repositoryNames<~Array> - List of repository names to describe
        #
        # ==== Returns
        # * response<~Excon::Response>:
        # * body<~Hash>:
        #   * nextToken<~String> - Token for pagination
        #   * repositories<~Array>:
        #     * createdAt<~Time> - When the repository was created
        #     * registoryId<~String> - AWS account ID associated with the registry
        #     * repositoryArn<~String> - ARN of the repository
        #     * repositoryName<~String> - Name of the repository
        #     * repositoryUri<~String> - URI of the repository

        def describe_repositories(params={})
          request({
            'Action' => 'DescribeRepositories'
          }.merge(params))
        end
      end

      class Mock
        def describe_repositories(params={})
          response     = Excon::Response.new
          repositories = self.data[:repositories].values

          if names = params['repositoryNames']
            repositories.select! { |r| names.include?(r['repositoryName']) }
          end

          response.body = {"repositories" => repositories}
          response
        end
      end
    end
  end
end
