class ApplicationMailer < ActionMailer::Base
  default from: AppSettings.fetch(:mailer_sender)
  layout "mailer"
end
