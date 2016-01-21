Shindo.tests("AWS::RDS | parameters", ['aws', 'rds']) do
  default_parameters = Fog::AWS[:rds].parameters.defaults("mysql5.5")

  returns(true) { default_parameters.first.is_a?(Fog::AWS::RDS::Parameter) }

  unless Fog.mocking?
    # this tests pagination
    returns(true) { default_parameters.count > 100 }
  end
end
