module FactoryHelpers
  def create_restricted_carrier(*args)
    stub_const("CarrierStanding::MAX_RESTRICTED_INTERACTIONS_PER_MONTH", 1)
    carrier = create(:carrier, :restricted, *args)
    create(:interaction, carrier:)
    carrier
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers
end
