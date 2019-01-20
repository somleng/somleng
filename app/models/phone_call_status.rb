class PhoneCallStatus
  NOT_ANSWERED_SIP_TERM_STATUSES = %w[480 487 603].freeze
  BUSY_SIP_TERM_STATUSES = ["486"].freeze

  attr_accessor :sip_term_status, :answer_time

  def initialize(options = {})
    self.sip_term_status = options.fetch(:sip_term_status)
    answer_epoch = options[:answer_epoch]
    self.answer_time = Time.at(answer_epoch.to_i) if answer_epoch.to_i.positive?
    self.answer_time ||= options[:answer_time]
  end

  def answered?
    answer_time.present?
  end

  def not_answered?
    NOT_ANSWERED_SIP_TERM_STATUSES.include?(sip_term_status)
  end

  def busy?
    BUSY_SIP_TERM_STATUSES.include?(sip_term_status)
  end
end
