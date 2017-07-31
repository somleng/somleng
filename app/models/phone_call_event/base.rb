class PhoneCallEvent::Base < ApplicationRecord
  self.table_name = :phone_call_events

  include Wisper::Publisher

  belongs_to :phone_call

  validates :type, :presence => true
  store_accessor :params, :sip_term_status, :answer_epoch

  after_commit   :publish_created, :on => :create

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

  def publish_created
    broadcast(broadcast_event_name(:created), self)
  end

  def broadcast_event_name(event_type)
    [phone_call_event_name, event_type].join("_")
  end

  def json_attributes
    {
      :id => nil,
      :params => nil,
      :updated_at => nil,
      :created_at => nil
    }
  end
end
