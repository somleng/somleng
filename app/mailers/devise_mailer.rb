class DeviseMailer < Devise::Mailer
  layout "carrier_mailer"
  helper ApplicationHelper

  def forgot_subdomain(user)
    devise_mail(user, :forgot_subdomain)
  end

  private

  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)
    @carrier = record.carrier
    @host = record.carrier_user? ? record.carrier.subdomain_host : record.carrier.account_host

    bootstrap_mail(headers_for(action, opts), &block)
  end
end
