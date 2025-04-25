class ApplicationWorkflow
  attr_reader :logger

  def initialize(*, **options)
    @logger = options.fetch(:logger) { Rails.logger }
  end

  def self.call(...)
    new(...).call
  end
end
