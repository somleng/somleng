class ApplicationWorkflow
  attr_accessor :attributes, :options

  def self.call(*args)
    new(*args).call
  end

  def initialize(options = {})
    self.options = options
  end
end
