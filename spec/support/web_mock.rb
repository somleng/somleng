require "webmock/rspec"

webdriver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }
WebMock.disable_net_connect!(allow_localhost: true, allow: [*webdriver_hosts])
