class DeviseMailer < Devise::Mailer
  layout "mailer"
  helper ApplicationHelper

  private

  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)

    @host = resolve_host(record)
    @carrier = record.carrier

    bootstrap_mail(headers_for(action, opts), &block)
  end

  def resolve_host(record)
    custom_domain = custom_domain_from(record, type: :dashboard)
    custom_domain ? custom_domain.host : default_host(record)
  end

  def default_host(record)
    URI(dashboard_root_url(subdomain: record.subdomain)).host
  end
end
