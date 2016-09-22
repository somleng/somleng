class CallDataRecord < ApplicationRecord
  DIRECTIONS = ["inbound", "outbound"]

  attachment :file, :content_type => ["application/json"]

  belongs_to :phone_call

  validates :phone_call, :file, :presence => true

  validates :duration_sec,
            :bill_sec,
            :presence => true,
            :numericality => { :greater_than_or_equal_to => 0 }

  validates :direction, :presence => true, :inclusion => { :in => DIRECTIONS }
  validates :hangup_cause, :presence => true

  def enqueue_process!(cdr)
    job_adapter.perform_later(cdr)
  end

  def process(raw_cdr)
    cdr = CDR::Freeswitch.new(raw_cdr)
    self.phone_call = PhoneCall.find_by_external_id(cdr.uuid)
    self.file_content_type, self.file_filename, self.file = cdr.to_file
    self.hangup_cause = cdr.hangup_cause
    self.direction = cdr.direction
    self.duration_sec = cdr.duration_sec
    self.bill_sec = cdr.bill_sec
    save!
  end

  private

  def job_adapter
    @job_adapter ||= JobAdapter.new(:call_data_record_worker)
  end
end
