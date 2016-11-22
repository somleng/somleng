class CallDataRecord < ApplicationRecord
  INBOUND_DIRECTION  = "inbound"
  OUTBOUND_DIRECTION = "outbound"

  DIRECTIONS = [INBOUND_DIRECTION, OUTBOUND_DIRECTION]

  attachment :file, :content_type => ["application/json"]

  belongs_to :phone_call

  validates :phone_call, :file, :presence => true

  validates :duration_sec,
            :bill_sec,
            :presence => true,
            :numericality => { :greater_than_or_equal_to => 0 }

  validates :direction, :presence => true, :inclusion => { :in => DIRECTIONS }
  validates :hangup_cause, :start_time, :end_time, :presence => true

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
    self.start_time = parse_epoch(cdr.start_epoch)
    self.end_time = parse_epoch(cdr.end_epoch)
    self.answer_time = parse_epoch(cdr.answer_epoch)
    self.sip_term_status = cdr.sip_term_status
    save
  end

  def self.outbound
    where(:direction => OUTBOUND_DIRECTION)
  end

  def self.billable
    where(self.arel_table[:bill_sec].gt(0))
  end

  def self.between_dates(start_date, end_date)
    on_or_after_date(start_date).on_or_before_date(end_date)
  end

  def self.on_or_after_date(date)
    date ? where(self.arel_table[:start_time].gteq(date)) : all
  end

  def self.on_or_before_date(date)
    date ? where(self.arel_table[:start_time].lteq(date)) : all
  end

  def self.bill_minutes
    bill_minutes_scope.sum(bill_minutes_sum)
  end

  def self.bill_minutes_scope
    billable
  end

  def self.bill_minutes_sum
    "((#{self.table_name}.bill_sec - 1) / 60) + 1"
  end

  private

  def parse_epoch(epoch)
    epoch = epoch.to_i
    Time.at(epoch) if epoch > 0
  end

  def job_adapter
    @job_adapter ||= JobAdapter.new(:call_data_record_worker)
  end
end
