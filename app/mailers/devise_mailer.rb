class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    sender = resolve_sender(record)
    @host = custom_domain_from(record, type: :dashboard)&.host
    opts.merge!(from: sender, reply_to: sender) if sender.present?
    super
  end

  private

  def resolve_sender(record)
    custom_domain = custom_domain_from(record, type: :mail)
    "contact@#{custom_domain.host}" if custom_domain.present?
  end

  def custom_domain_from(record, type:)
    custom_domain = record.carrier.custom_domain(type)

    return if custom_domain.blank?
    return unless custom_domain.verified?

    custom_domain
  end
end
