# All files for Configurations & reporting
require 'active_support/all'
require 'rspec'
require 'bdd/rspec'
require 'allure-rspec'
require 'selenium-webdriver'
require 'require_all'
require 'site_prism'
require "chromedriver-helper"

require_rel '../config'
require_rel '../helpers'
require_rel '../lib'
require_rel '../pages'

include Config::AllureConfig

RSpec.configure do |config|
  config.before(:example) do
    @browser = initialize_browser
  end

  config.after(:example) do |example|
    if example.exception
      rescue_standard_error do
        CustomFormatter.instance_variable_set(:@url, @browser.current_url)
      end
    end
    rescue_standard_error { @browser.driver&.quit }
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.color = true
  config.default_formatter = CustomFormatter
  config.run_all_when_everything_filtered = false
  config.order = :defined # run specs top down
  config.fail_fast = false
  config.example_status_persistence_file_path = 'tmp/rspec_failures/failed_examples.txt'

  yield config if block_given?
end

# Allure config
allure_config
allure_screenshot
