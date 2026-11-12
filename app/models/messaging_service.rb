class MessagingService < ApplicationRecord
  class SenderPool
    Sender = Data.define(:alphanumeric_sender_id, :incoming_phone_number, :sender_id) do
      def initialize(**)
        super(alphanumeric_sender_id: nil, incoming_phone_number: nil, **)
      end
    end

    attr_reader :messaging_service, :phone_number_parser

    def initialize(messaging_service)
      @messaging_service = messaging_service
    end

    def choose_sender(country_code:)
      if (alphanumeric_sender_id = alphanumeric_sender_ids_for(country_code:).first).present?
        Sender.new(alphanumeric_sender_id:, sender_id: alphanumeric_sender_id.sender_id)
      elsif (incoming_phone_number = incoming_phone_numbers.order("RANDOM()").first).present?
        Sender.new(incoming_phone_number:, sender_id: incoming_phone_number.number)
      end
    end

    def any_for?(country_code:)
      return true if incoming_phone_numbers.exists?

      alphanumeric_sender_ids.joins(
        :messaging_service_alphanumeric_sender_ids
      ).merge(alphanumeric_sender_ids_for(country_code:)).exists?
    end

    def alphanumeric_sender_ids_for(country_code:)
      alphanumeric_sender_ids.where(
        messaging_service_alphanumeric_sender_ids: {
          destination_country_code: [ country_code, nil ]
        }
      ).order(MessagingServiceAlphanumericSenderID.arel_table[:destination_country_code].asc.nulls_last)
    end

    def size
      pool.sum(&:size)
    end

    def incoming_phone_numbers
      messaging_service.incoming_phone_numbers.active
    end

    def alphanumeric_sender_ids
      messaging_service.alphanumeric_sender_ids.approved
    end

    private

    def pool
      @pool ||= [ incoming_phone_numbers, alphanumeric_sender_ids ]
    end
  end

  extend Enumerize

  belongs_to :account
  belongs_to :carrier
  has_many :incoming_phone_numbers
  has_many :messages
  has_many :messaging_service_alphanumeric_sender_ids
  has_many :alphanumeric_sender_ids,
           through: :messaging_service_alphanumeric_sender_ids,
           source: :sender_id

  enumerize :inbound_request_method, in: %w[POST GET]

  enumerize :inbound_message_behavior,
            in: %i[defer_to_sender drop webhook]

  def sender_pool
    @sender_pool ||= SenderPool.new(self)
  end
end
