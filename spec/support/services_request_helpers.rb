RSpec.configure do |config|
  config.before(:each, :services, type: :request) do
    host! "services.somleng.org"
  end
end
