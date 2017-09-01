class PhoneCallEvent::Base < ApplicationRecord
  self.table_name = :phone_call_events

  include EventPublisher

  belongs_to :phone_call
  belongs_to :recording, :optional => true

  validates :type, :presence => true

  def serializable_hash(options = nil)
    options ||= {}
    super(
      {
        :only => json_attributes.keys,
        :include => [:phone_call]
      }.merge(options)
    )
  end

  private

  def json_attributes
    {
      :id => nil,
      :params => nil,
      :updated_at => nil,
      :created_at => nil
    }
  end
end
