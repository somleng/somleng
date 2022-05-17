RSpec.configure do |config|
  config.include(Devise::Test::IntegrationHelpers, type: :system)
  config.include(Devise::Test::IntegrationHelpers, type: :request)
end
