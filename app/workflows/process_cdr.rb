class ProcessCDR
  def self.call(*, **)
    ProcessCDRJob.perform_later(*)
  end
end
