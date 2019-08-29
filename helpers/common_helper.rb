def wait(seconds)
  Selenium::WebDriver::Wait.new(timeout: seconds)
end