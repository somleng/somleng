class ApplicationMailer < ActionMailer::Base
  default from: AppSettings.config_for(:mailer_sender)
  layout "mailer"
end
