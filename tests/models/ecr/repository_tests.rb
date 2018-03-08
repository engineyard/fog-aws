Shindo.tests("AWS::ECR | repository", ['aws', 'ecr']) do
  model_tests(Fog::AWS[:ecr].repositories, {:name => uniq_id('fogtest')})
  collection_tests(Fog::AWS[:ecr].repositories, {:name => uniq_id('fogtest')})
end
