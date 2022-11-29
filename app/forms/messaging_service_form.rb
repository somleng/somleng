class MessagingServiceForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  extend Enumerize

  attribute :carrier
  attribute :account_id
  attribute :account
  attribute :phone_numbers, default: []
  attribute :name
  attribute :inbound_request_url
  attribute :inbound_request_method
  attribute :status_callback_url
  attribute :status_callback_method
  attribute :messaging_service, default: -> { MessagingService.new }
  attribute :smart_encoding, :boolean

  validates :name, presence: true
  validates :account_id, presence: true, if: :new_record?

  validates :inbound_request_url,
            :status_callback_url,
            url_format: { allow_http: true },
            allow_blank: true

  validates :inbound_request_method,
            inclusion: { in: MessagingService.inbound_request_method.values },
            allow_blank: true

  validates :status_callback_method,
            inclusion: { in: MessagingService.status_callback_method.values },
            allow_blank: true

  delegate :persisted?, :new_record?, :id, to: :messaging_service

  def self.model_name
    ActiveModel::Name.new(self, nil, "MessagingService")
  end

  def self.initialize_with(messaging_service)
    new(
      messaging_service:,
      name: messaging_service.name,
      account: messaging_service.account,
      carrier: messaging_service.carrier,
      phone_numbers: messaging_service.phone_numbers,
      inbound_request_url: messaging_service.inbound_request_url,
      inbound_request_method: messaging_service.inbound_request_method,
      status_callback_url: messaging_service.status_callback_url,
      status_callback_method: messaging_service.status_callback_method,
      smart_encoding: messaging_service.smart_encoding
    )
  end

  def save
    return false if invalid?

    messaging_service.carrier = carrier
    messaging_service.name = name
    messaging_service.account ||= find_account
    messaging_service.phone_number_ids = phone_numbers.reject(&:blank?)
    messaging_service.inbound_request_url = inbound_request_url.presence
    messaging_service.inbound_request_method = inbound_request_method
    messaging_service.status_callback_url = status_callback_url.presence
    messaging_service.status_callback_method = status_callback_method
    messaging_service.smart_encoding = smart_encoding

    messaging_service.save!
  end

  def account_options_for_select
    accounts_scope.map { |account| [account.name, account.id] }
  end

  def phone_numbers_options_for_select
    (phone_numbers_scope + phone_numbers).map do |phone_number|
      [phone_number.number, phone_number.id]
    end
  end

  private

  def find_account
    accounts_scope.find(account_id)
  end

  def accounts_scope
    carrier.accounts.carrier_managed
  end

  def phone_numbers_scope
    account.phone_numbers.where.not(id: account.messaging_service_senders.select(:phone_number_id))
  end
end
