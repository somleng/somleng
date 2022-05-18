class DeviseMailer < Devise::Mailer
  layout "mailer"
  helper ApplicationHelper

  private

  def devise_mail(record, action, opts = {}, &block)
    initialize_from_record(record)

    @host = resolve_host(record)
    @carrier = record.carrier
    sender = resolve_sender(record)
    opts.merge!(from: sender, reply_to: sender) if sender.present?

    bootstrap_mail(headers_for(action, opts), &block)
  end

  def resolve_sender(record)
    custom_domain = custom_domain_from(record, type: :mail)
    "no-reply@#{custom_domain.host}" if custom_domain.present?
  end

  def resolve_host(record)
    custom_domain = custom_domain_from(record, type: :dashboard)
    custom_domain ? custom_domain.host : Rails.configuration.app_settings.fetch(:dashboard_url_host)
  end

  def custom_domain_from(record, type:)
    custom_domain = record.carrier.custom_domain(type)

    return if custom_domain.blank?
    return unless custom_domain.verified?

    custom_domain
  end
end
