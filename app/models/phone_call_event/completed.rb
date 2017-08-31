class PhoneCallEvent::Completed < PhoneCallEvent::Base
  NOT_ANSWERED_SIP_TERM_STATUSES = [
    "480", "487", "603"
  ]

  BUSY_SIP_TERM_STATUSES = [
    "486"
  ]

  store_accessor :params, :sip_term_status, :answer_epoch

  attr_accessor :answer_time

  def answered?
    answer_epoch.to_i > 0 || !!answer_time
  end

  def not_answered?
    NOT_ANSWERED_SIP_TERM_STATUSES.include?(sip_term_status)
  end

  def busy?
    BUSY_SIP_TERM_STATUSES.include?(sip_term_status)
  end

  def self.to_event_name
    :phone_call_event_completed
  end
end
