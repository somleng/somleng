class PhoneCallEvent < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :phone_call
  belongs_to :recording, optional: true

  store_accessor :params, :sip_term_status, :answer_epoch

  def self.completed
    where(type: :completed)
  end
end
