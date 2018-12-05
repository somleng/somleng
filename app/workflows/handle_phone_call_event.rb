class HandlePhoneCallEvent < ApplicationWorkflow
  attr_accessor :event

  def initialize(event)
    self.event = event
  end
end
