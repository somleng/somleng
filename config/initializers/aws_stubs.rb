if Rails.env.development? || Rails.env.test?
  sesv2_client = Aws::SESV2::Client.new
  create_email_identity_response = sesv2_client.stub_data(:create_email_identity)
  create_email_identity_response.dkim_attributes.tokens = %w[token-1 token-2 token-3]

  Aws.config[:ec2] ||= {
    stub_responses: {
      revoke_security_group_ingress: Aws::EC2::Client.new.stub_data(:revoke_security_group_ingress),
      authorize_security_group_ingress: Aws::EC2::Client.new.stub_data(:authorize_security_group_ingress)
    }
  }

  Aws.config[:sesv2] ||= {
    stub_responses: {
      create_email_identity: create_email_identity_response,
      get_email_identity: sesv2_client.stub_data(:get_email_identity),
      delete_email_identity: sesv2_client.stub_data(:delete_email_identity)
    }
  }
end
