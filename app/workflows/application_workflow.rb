class ApplicationWorkflow
  class WorkflowArgumentError < StandardError; end

  def self.call(...)
    new(...).call
  end
end
