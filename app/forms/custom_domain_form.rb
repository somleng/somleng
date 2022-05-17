class CustomDomainForm
  class HostUniquenessValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      scope = options.fetch(:scope) { CustomDomain.verified }
      return unless scope.exists?(host: value)

      record.errors.add(attribute, options.fetch(:message, :taken))
    end
  end

  class HostnameValidator < ActiveModel::EachValidator
    RESTRICTED_DOMAINS = [
      Addressable::URI.parse(Rails.configuration.app_settings.fetch(:dashboard_url_host)).domain,
      Addressable::URI.parse(Rails.configuration.app_settings.fetch(:api_url_host)).domain,
      Mail::Address.new(Rails.configuration.app_settings.fetch(:mailer_sender)).domain
    ].freeze

    def validate_each(record, attribute, value)
      return unless Addressable::URI.parse("//#{value}").domain.in?(RESTRICTED_DOMAINS)

      record.errors.add(attribute, options.fetch(:message, :exclusion))
    rescue Addressable::URI::InvalidURIError
      record.errors.add(attribute, :invalid)
    end
  end

  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :carrier
  attribute :dashboard_host, HostnameType.new
  attribute :api_host, HostnameType.new
  attribute :mail_host, HostnameType.new

  delegate :persisted?, :id, to: :carrier

  validates :dashboard_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validates :api_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validates :mail_host,
            presence: true,
            hostname: true,
            host_uniqueness: true

  validate :validate_hosts

  def self.model_name
    ActiveModel::Name.new(self, nil, "CustomDomain")
  end

  def self.initialize_with(carrier)
    new(carrier:)
  end

  def save
    return false if invalid?

    CustomDomain.transaction do
      configure_custom_domain!(host_type: :dashboard, type: CustomDomain, host: dashboard_host, dns_record_type: :txt)
      configure_custom_domain!(host_type: :api, type: CustomDomain, host: api_host, dns_record_type: :txt)
      configure_custom_domain!(host_type: :mail, type: MailCustomDomain, host: mail_host, dns_record_type: :cname) do |custom_domain|
        CreateEmailIdentity.call(custom_domain)
      end
    end

    true
  end

  def regenerate_mail_domain_identity
    mail_custom_domain = carrier.custom_domain(:mail)
    DeleteEmailIdentity.call(mail_custom_domain.host)
    CreateEmailIdentity.call(mail_custom_domain)
  end

  private

  def configure_custom_domain!(attributes)
    custom_domain = CustomDomain.create!(
      verification_started_at: Time.current,
      carrier:,
      **attributes
    )

    yield(custom_domain) if block_given?

    VerifyCustomDomainJob.set(wait: 15.minutes).perform_later(
      custom_domain
    )
  end

  def validate_hosts
    hosts = { mail_host:, api_host:, dashboard_host: }.compact
    duplicate_hosts = hosts.find { |_key, host| hosts.values.count(host) > 1 }
    return if duplicate_hosts.blank?

    errors.add(duplicate_hosts[0], :other_than, count: duplicate_hosts[1])
  end
end
