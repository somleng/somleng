ENV["AWS_DEFAULT_REGION"] ||= "ap-southeast-1"

Aws.config[:ec2] ||= {
  stub_responses: {
    revoke_security_group_ingress: Aws::EC2::Client.new.stub_data(:revoke_security_group_ingress),
    authorize_security_group_ingress: Aws::EC2::Client.new.stub_data(:authorize_security_group_ingress)
  }
}

Aws.config[:sesv2] ||= {
  stub_responses: {
    create_email_identity: Aws::SESV2::Client.new.stub_data(:create_email_identity),
    get_email_identity: Aws::SESV2::Client.new.stub_data(:get_email_identity)
  }
}
