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

  def choices_select(value, from:, **options)
    return select(value, from:, **options) if Capybara.current_driver == :rack_test

    choices_wrapper = find_field(from, visible: false).find(:xpath, "../..")
    choices_wrapper.click

    dropdown = choices_wrapper.find(:xpath, ".//div[contains(@class, 'choices__list--dropdown')]")

    item_xpath = if value.present?
      if options[:exact] == true
        ".//div[contains(@class, 'choices__item') and normalize-space(text())='#{value}']"
      else
        ".//div[contains(@class, 'choices__item') and contains(., '#{value}')]"
      end
    else
      ".//div[contains(@class, 'choices__item') and not(text())]"
    end

    item = dropdown.find(:xpath, item_xpath)
    item.click
  end

  def have_choices_select(locator = nil, **options)
    options[:visible] = false unless Capybara.current_driver == :rack_test
    have_select(locator, **options)
  end
end

RSpec.configure do |config|
  config.include SystemSpecHelpers, type: :system
end
