class PhoneCallEvent::Base < ApplicationRecord
  self.table_name = :phone_call_events
  belongs_to :phone_call

  validates :phone_call, :presence => true
  validates :type, :presence => true

  store_accessor :params, :sip_term_status, :answer_epoch

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
