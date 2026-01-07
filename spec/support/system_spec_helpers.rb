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

  def enhanced_select(*values, from:, **options)
    if Capybara.current_driver == :rack_test
      values.each do |value|
        select(value, from:, **options)
      end

      return
    end

    control_wrapper = find_field(from, visible: false).find(:xpath, "..")
    control_wrapper.click


    values.each do |value|
      option = if options[:exact]
        control_wrapper.first(:xpath, "..//*[text()='#{value}']")
      else
        control_wrapper.first(:xpath, "..//*[contains(text(), '#{value}')]")
      end

      option.click
    end
  end

  def have_enhanced_select(locator = nil, **options)
    options[:visible] = false unless Capybara.current_driver == :rack_test
    have_select(locator, **options)
  end

  def stub_rating_engine_request
    stub_request(:post, "#{AppSettings.fetch(:rating_engine_host)}/jsonrpc").to_return ->(request) {
      {
        status: 200,
        body: JSON.parse(request.body).slice("id").merge(result: "OK", error: nil).to_json,
        headers: { "Content-Type" => "application/json" }
      }
    }
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
