class ForgotSubdomainMailer < ApplicationMailer
  def forgot_subdomain(email:, carriers:)
    @email = email
    @carriers = carriers
    bootstrap_mail(to: email, subject: "Somleng - Forgot Subdomain")
  end
end
