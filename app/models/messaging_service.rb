class MessagingService < ApplicationRecord
  class SenderPool
    attr_reader :messaging_service, :phone_number_parser

    def initialize(messaging_service, phone_number_parser: Phony)
      @messaging_service = messaging_service
      @phone_number_parser = phone_number_parser
    end

    def incoming_phone_numbers
      messaging_service.incoming_phone_numbers.active
    end

    def alphanumeric_sender_ids
      messaging_service.alphanumeric_sender_ids.approved
    end

    def any_for?(destination:)
      return true if incoming_phone_numbers.any?

      alphanumeric_sender_ids.joins(
        :messaging_service_alphanumeric_sender_ids
      ).merge(alphanumeric_sender_ids_for(destination:)).exists?
    end

    def alphanumeric_sender_ids_for(destination:)
      alphanumeric_sender_ids.where(
        messaging_service_alphanumeric_sender_ids: {
          destination_country_code: [ country_code(destination), nil ]
        }
      )
    end

    def size
      pool.sum(&:size)
    end

    private

    def pool
      @pool ||= [ incoming_phone_numbers, alphanumeric_sender_ids ]
    end

    def country_code(number)
      phone_number_parser.split(number).first
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
