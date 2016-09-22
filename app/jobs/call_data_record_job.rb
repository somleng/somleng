class CallDataRecordJob < ActiveJob::Base
  def perform(cdr)
    CallDataRecord.new.process(cdr)
  end
end
