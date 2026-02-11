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
        plan.schedules.each do |schedule|
          client.upsert_tariff_schedule(schedule)
        end

        client.upsert_tariff_plan(plan)
      end

      package
    end
  end
end
