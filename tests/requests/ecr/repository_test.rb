Shindo.tests('AWS::ECS | repository tests', ['aws', 'ecr']) do
  @repository_format = {
    "registryId"     => String,
    "repositoryArn"  => String,
    "repositoryName" => String,
    "repositoryUri"  => String,
    "createdAt"      => Float
  }

  @create_destroy_repository_result = {
    "repository" => @repository_format
  }

  @describe_repositories_result = {
    "nextToken"    => Fog::Nullable::String,
    "repositories" => [@repository_format]
  }

  tests('success') do
    @repository_name = uniq_id('fogtest')

    tests("#create_repository('#{@repository_name}')").formats(@create_destroy_repository_result) do
      Fog::AWS[:ecr].create_repository(@repository_name).body
    end

    tests("#describe_repositories").formats(@describe_repositories_result) do
      Fog::AWS[:ecr].describe_repositories.body
    end

    tests("#describe_repositories('repositoryNames' => ['#{@repository_name}'])").formats(@describe_repositories_result) do
      result = Fog::AWS[:ecr].describe_repositories('repositoryNames' => [@repository_name]).body
      returns(1) { result["repositories"].count }
      result
    end

    tests("#delete_repository('#{@repository_name}')").formats(@create_destroy_repository_result) do
      Fog::AWS[:ecr].delete_repository(@repository_name).body
    end
  end
end
