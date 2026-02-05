class CreateTariffPackageWizardForm < ApplicationWorkflow
  attr_reader :resource, :client

  def initialize(resource, **options)
    super()
    @resource = resource
    @client = options.fetch(:client) { RatingEngineClient.new }
  end

  def call
    ApplicationRecord.transaction do
      return unless resource.save

      package = resource.object
      destination_group = package.carrier.destination_groups.find_by!(catch_all: true)
      client.upsert_destination_group(destination_group)

      package.plans.each do |plan|
        client.upsert_tariff_plan(plan)

        plan.schedules.each do |schedule|
          client.upsert_tariff_schedule(schedule)
        end
      end

      package
    end
  end
end
