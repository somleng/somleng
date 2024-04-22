class PhoneNumber < ApplicationRecord
  self.inheritance_column = :_type_disabled

  NUMBER_FORMAT = /\A\d+\z/
  SHORT_CODE_TYPES = [ :short_code ].freeze
  E164_TYPES = [ :local, :mobile, :toll_free ].freeze
  TYPES = (SHORT_CODE_TYPES + E164_TYPES).freeze

  extend Enumerize

  enumerize :type, in: TYPES

  belongs_to :carrier
  belongs_to :account, optional: true
  has_many :phone_calls
  has_many :messages
  has_one :configuration, class_name: "PhoneNumberConfiguration"

  delegate :configured?, to: :configuration, allow_nil: true

  validates :number,
            presence: true,
            uniqueness: { scope: :carrier_id },
            format: { with: NUMBER_FORMAT, allow_blank: true }

  validates :iso_country_code, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }
  validates :type, phone_number_type: true

  class << self
    def available
      enabled.unassigned
    end

    def assigned
      where.not(account_id: nil)
    end

    def unassigned
      where(account_id: nil)
    end

    def enabled
      where(enabled: true)
    end

    def supported_countries
      select(:iso_country_code).distinct.order(:iso_country_code)
    end

    def utilized
      scope = assigned.left_joins(account: :phone_calls).left_joins(account: :messages)
              .where.not(phone_calls: { phone_number_id: nil }).or(where.not(messages: { phone_number_id: nil }))
              .distinct

      where(id: scope.select(:id))
    end

    def unutilized
      assigned_unutilized = assigned.left_joins(account: :phone_calls).left_joins(account: :messages)
                            .where(phone_calls: { phone_number_id: nil }, messages: { phone_number_id: nil })

      unassigned.or(where(id: assigned_unutilized.select(:id)))
    end

    def configured
      joins(:configuration).merge(PhoneNumberConfiguration.configured)
    end

    def unconfigured
      left_joins(:configuration).merge(PhoneNumberConfiguration.unconfigured)
    end
  end

  def country
    ISO3166::Country.new(iso_country_code)
  end

  def release!
    transaction do
      update!(account: nil)
      configuration&.destroy!
    end
  end

  def assigned?
    account_id.present?
  end

  def utilized?
    return unless assigned?

    account.phone_calls.where(phone_number_id: id).any? || account.messages.where(phone_number_id: id).any?
  end
end
