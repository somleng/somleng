require "selenium/webdriver"

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test

    Capybara.server = :puma, { Silent: true }
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  config.before(:each, type: :system, selenium_chrome: true) do
    driven_by :selenium, using: :chrome
  end
end
