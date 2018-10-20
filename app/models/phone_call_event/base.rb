class PhoneCallEvent::Base < ApplicationRecord
  self.table_name = :phone_call_events

  include EventPublisher

  belongs_to :phone_call
  belongs_to :recording, optional: true

  validates :type, presence: true

  delegate :url, to: :recording, prefix: true, allow_nil: true

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        only: json_attributes.keys,
        methods: json_methods.keys
      }.merge(options)
    )
  end

  private

  def json_attributes
    {}
  end

  def json_methods
    {
      recording_url: nil
    }
  end
end
