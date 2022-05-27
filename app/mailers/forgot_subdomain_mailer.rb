class ForgotSubdomainMailer < ApplicationMailer
  def forgot_subdomain(user)
    @user = user
    @carriers = Carrier.joins(:carrier_users).where(users: { email: user.email })
    bootstrap_mail(to: user.email, subject: "Somleng - Forgot Subdomain")
  end
end
