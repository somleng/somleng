class ProcessOutboundCallsQueue < ApplicationWorkflow
  def call
    OutboundCallsQueue.each_queue do |queue|
      queue.recover!(processing_longer_than: 1.minute.ago)

      [ queue.size, 60 ].min.times { OutboundCallJob.perform_later(queue.account) }
    end
  end
end
