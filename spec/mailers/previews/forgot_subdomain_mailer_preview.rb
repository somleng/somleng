class ForgotSubdomainMailerPreview < ActionMailer::Preview
  def forgot_subdomain
    ForgotSubdomainMailer.forgot_subdomain(
      email: "bobchann@example.com", carriers: [Carrier.first]
    )
  end
end
