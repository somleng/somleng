class UpsertRatingEngineResource
  attr_reader :client

  def initialize(**options)
    super()
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call(resource, remote_action:)
    ApplicationRecord.transaction do
      resource.save!
      remote_action.call(resource, client)
    end
  end
end
