class ForgotSubdomainMailerPreview < ActionMailer::Preview
  def forgot_subdomain
    user = User.last
    ForgotSubdomainMailer.forgot_subdomain(user)
  end
end
