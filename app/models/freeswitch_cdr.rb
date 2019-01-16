class FreeswitchCDR
  CONTENT_TYPE = "application/json".freeze

  attr_accessor :raw_data, :data, :io, :filename, :content_type

  def initialize(raw_data)
    self.raw_data = raw_data
    self.data = JSON.parse(raw_data)
    self.io = StringIO.new(raw_data)
    self.filename = "a_" + uuid + ".cdr.json"
    self.content_type = CONTENT_TYPE
  end

  def uuid
    variables["uuid"]
  end

  def duration_sec
    variables["duration"].to_i
  end

  def bill_sec
    variables["billsec"].to_i
  end

  def direction
    variables["direction"]
  end

  def hangup_cause
    variables["hangup_cause"]
  end

  def sip_term_status
    variables["sip_term_status"]
  end

  def sip_invite_failure_status
    variables["sip_invite_failure_status"]
  end

  def sip_invite_failure_phrase
    CGI.unescape(variables["sip_invite_failure_phrase"].to_s).presence
  end

  def variables
    data.fetch("variables") { {} }
  end

  def start_time
    parse_epoch(start_epoch)
  end

  def end_time
    parse_epoch(end_epoch)
  end

  def answer_time
    parse_epoch(answer_epoch)
  end

  private

  def parse_epoch(epoch)
    return if epoch.to_i.zero?

    Time.at(epoch.to_i)
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
end
