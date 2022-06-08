module SystemSpecHelpers
  def carrier_sign_in(user)
    set_app_host(user.carrier)
    sign_in(user)
  end

  def set_app_host(carrier)
    Capybara.app_host = "http://#{carrier.subdomain_host}"
  end

  def accept_confirm(*)
    Capybara.current_driver == :rack_test ? yield : super
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
