class DeviseMailer < Devise::Mailer
  layout "mailer"
  helper ApplicationHelper

  private

  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)
    @carrier = record.carrier
    @host = record.carrier_user? ? record.carrier.subdomain_host : record.carrier.account_host

    bootstrap_mail(headers_for(action, opts), &block)
  end
end
