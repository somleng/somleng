class MessagingServiceForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  extend Enumerize

  INBOUND_MESSAGE_BEHAVIORS = {
    defer_to_sender: "Defer to sender's webhook <div class='form-text'>Invoke the sender's HTTP webhook (if it is defined) for incoming messages.</div>",
    drop: "Drop the message <div class='form-text'>Your application will ignore messages. You won't be billed for incoming messages.</div>",
    webhook: "Send a webhook <div class='form-text'>Invoke an HTTP webhook for all incoming messages.</div>"
  }.freeze

  attribute :carrier
  attribute :account_id
  attribute :account
  attribute :phone_number_ids, FilledArrayType.new, default: []
  attribute :name
  attribute :inbound_request_url
  attribute :inbound_request_method
  attribute :status_callback_url
  attribute :messaging_service, default: -> { MessagingService.new }
  attribute :smart_encoding, :boolean, default: true
  attribute :inbound_message_behavior, default: :defer_to_sender

  enumerize :inbound_message_behavior,
            in: MessagingService.inbound_message_behavior.values

  validates :name, presence: true
  validates :account_id, presence: true, if: :validate_account_id?
  validate :validate_phone_numbers, if: :persisted?

  validates :inbound_request_url,
            url_format: { allow_http: true, allow_blank: true },
            presence: { if: -> { inbound_message_behavior.webhook? } }

  validates :inbound_request_method,
            inclusion: { in: MessagingService.inbound_request_method.values, allow_blank: true },
            presence: { if: -> { inbound_request_url.present? } }

  validates :status_callback_url,
            url_format: { allow_http: true },
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
      account_id: messaging_service.account.id,
      carrier: messaging_service.carrier,
      phone_number_ids: messaging_service.phone_number_ids,
      inbound_message_behavior: messaging_service.inbound_message_behavior,
      inbound_request_url: messaging_service.inbound_request_url,
      inbound_request_method: messaging_service.inbound_request_method,
      status_callback_url: messaging_service.status_callback_url,
      smart_encoding: messaging_service.smart_encoding
    )
  end

  def save
    return false if invalid?

    messaging_service.carrier = carrier
    messaging_service.name = name
    messaging_service.account ||= find_account
    messaging_service.inbound_request_url = inbound_request_url.presence
    messaging_service.inbound_request_method = inbound_request_method
    messaging_service.status_callback_url = status_callback_url.presence
    messaging_service.smart_encoding = smart_encoding
    messaging_service.inbound_message_behavior = inbound_message_behavior

    MessagingService.transaction do
      messaging_service.save!
      update_senders!
    end

    messaging_service
  end

  def account_options_for_select
    accounts_scope.map { |account| [ account.name, account.id ] }
  end

  def phone_numbers_options_for_select
    PhoneNumber.where(id: sender_pool_select.all_values).map do |phone_number|
      [ phone_number.decorated.number_formatted, phone_number.id ]
    end
  end

  def inbound_message_behavior_options_for_select
    INBOUND_MESSAGE_BEHAVIORS.map { |k, v| [ v.html_safe, k ] }
  end

  private

  def find_account
    return account if account.present?

    self.account = accounts_scope.find(account_id)
  end

  def accounts_scope
    carrier.accounts.carrier_managed
  end

  def validate_account_id?
    account.blank? && new_record?
  end

  def validate_phone_numbers
    return if errors.any?
    return if sender_pool_select.valid?

    errors.add(:phone_number_ids, :invalid)
  end

  def update_senders!
    attributes = sender_pool_select.values_to_remove.map do |phone_number_id|
      { phone_number_id:, messaging_service_id: nil }
    end

    attributes += sender_pool_select.values_to_add.map do |phone_number_id|
      { phone_number_id:, messaging_service_id: messaging_service.id }
    end

    return if attributes.empty?

    PhoneNumberConfiguration.upsert_all(attributes, unique_by: :phone_number_id)
  end

  def sender_pool_select
    @sender_pool_select ||= MultiSelectFormComponent.new(
      selected_values: phone_number_ids,
      available_values: account.phone_numbers.left_joins(:configuration)
                                .where(phone_number_configurations: { messaging_service_id: nil }).pluck(:id),
      existing_values: messaging_service.phone_numbers.pluck(:id)
    )
  end
end
