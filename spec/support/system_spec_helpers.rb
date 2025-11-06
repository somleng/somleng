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

  def enhanced_select(value, from:, **options)
    return select(value, from:, **options) if Capybara.current_driver == :rack_test

    control_wrapper = find_field(from, visible: false).find(:xpath, "..")
    control_wrapper.click
    control_wrapper.find(:xpath, "..//*[text()='#{value}']").click
  end

  def have_enhanced_select(locator = nil, **options)
    options[:visible] = false unless Capybara.current_driver == :rack_test
    have_select(locator, **options)
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
