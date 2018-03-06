Shindo.tests('Fog::Compute[:aws] | iam profile attachment requests', ['aws']) do
  @association_format = {
    "iamInstanceProfile" => {
      "arn" => String,
      "id"  => String
    },
    "associationId" => String,
    "instanceId"    => String,
    "state"         => String
  }

  @association_result = {
    'iamInstanceProfileAssociation' => @association_format,
    "requestId" => String
  }

  @describe_instance_profile_association_result = {
    'iamInstanceProfileAssociations' => [@association_format],
    'requestId' => String
  }

  tests('success') do
    @rolename = uniq_id("fogrole")
    @role = Fog::AWS[:iam].roles.create(rolename: @rolename)
    @role.attach("arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role") unless Fog.mocking?
    @instance_profile_name = 'ecsInstanceRole'
    @instance_profile = Fog::AWS[:iam].instance_profiles.create(name: @instance_profile_name)
    Fog::AWS[:iam].add_role_to_instance_profile(@rolename, @instance_profile_name)
    @instance_id = Fog::Compute[:aws].run_instances('ami-79c0ae10', 1, 1, 'InstanceType' => 't1.micro', 'BlockDeviceMapping' => [{"DeviceName" => "/dev/sdp1", "VirtualName" => nil, "Ebs.VolumeSize" => 15}]).body['instancesSet'].first['instanceId']
    Fog.wait_for { Fog::Compute[:aws].servers.get(@instance_id).state == 'running' } unless Fog.mocking?
    @association_id = nil

    tests("#associate_iam_instance_profile('#{@instance_id}', '#{@instance_profile_name}')").formats(@association_result) do
      data = Fog::Compute[:aws].associate_iam_instance_profile(@instance_id, @instance_profile_name).body
      returns('associating') { data['iamInstanceProfileAssociation']['state'] }
      @association_id = data['iamInstanceProfileAssociation']['associationId']
      data
    end

    unless Fog.mocking?
      Fog.wait_for { Fog::Compute[:aws].describe_iam_instance_profile_associations.body['iamInstanceProfileAssociations'].detect { |h| h['associationId'] == @association_id }['state'] == 'associated' }
    end

    tests("#describe_iam_instance_profile_associations").formats(@describe_instance_profile_association_result) do
      data = Fog::Compute[:aws].describe_iam_instance_profile_associations.body
      returns('associated') { data['iamInstanceProfileAssociations'].detect { |h| h['associationId'] == @association_id }['state'] }
      data
    end

    tests("#disassociate_iam_instance_profile('#{@association_id}')").formats(@association_result) do
      data = Fog::Compute[:aws].disassociate_iam_instance_profile(@association_id).body
      returns('disassociating') { data['iamInstanceProfileAssociation']['state'] }
      data
    end

    Fog::Compute[:aws].terminate_instances(@instance_id)
    Fog::AWS[:iam].remove_role_from_instance_profile(@rolename, @instance_profile_name)
    @role.detach("arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role") unless Fog.mocking?
    @instance_profile.destroy
    @role.destroy
  end
end
