class ProcessOutboundCallsQueue < ApplicationWorkflow
  def call
    OutboundCallsQueue.each_queue do |queue|
      next if queue.size.zero?

      [ queue.size, 60 ].min.times { OutboundCallJob.perform_later(queue.account) }
    end
  end
end
