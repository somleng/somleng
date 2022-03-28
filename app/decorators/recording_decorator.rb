class RecordingDecorator < SimpleDelegator
  STATUS_MAPPINGS = {
    "in_progress" => "processing",
    "completed" => "completed"
  }.freeze

  def sid
    object.id
  end

  def duration
    object.duration.to_s.presence
  end

  def start_time
    created_at
  end

  def channels
    1
  end

  def source
    "RecordVerb"
  end

  def status
    STATUS_MAPPINGS.fetch(object.status)
  end

  def track
    "both"
  end

  private

  def object
    __getobj__
  end
end
