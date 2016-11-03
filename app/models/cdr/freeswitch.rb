class CDR::Freeswitch
  attr_accessor :raw_cdr, :cdr

  def initialize(raw_cdr)
    self.raw_cdr = raw_cdr
    self.cdr = JSON.parse(raw_cdr)
  end

  def uuid
    variables["uuid"]
  end

  def to_file
    [content_type, filename, string_io]
  end

  def duration_sec
    variables["duration"]
  end

  def bill_sec
    variables["billsec"]
  end

  def direction
    variables["direction"]
  end

  def hangup_cause
    variables["hangup_cause"]
  end

  def start_epoch
    variables["start_epoch"]
  end

  def end_epoch
    variables["end_epoch"]
  end

  def answer_epoch
    variables["answer_epoch"]
  end

  def sip_term_status
    variables["sip_term_status"]
  end

  private

  def filename
    "a_" + uuid + ".cdr.json"
  end

  def string_io
    StringIO.new(raw_cdr)
  end

  def content_type
    "application/json"
  end

  def variables
    cdr["variables"] || {}
  end
end
