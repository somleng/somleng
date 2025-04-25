class ProcessOutboundCallsQueue < ApplicationWorkflow
  def call
    OutboundCallsQueue.each_queue do |queue|
      queue.size.times { OutboundCallJob.perform_later(queue.account) }
    end
  end
end
