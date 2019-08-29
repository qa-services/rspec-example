require 'selenium-webdriver'

module Lib
  class RemoteDriver
    attr_reader :driver

    # initialise browser type e.g. chrome/firefox
    # setup timeout and implicit waits
    def initialize
      client.read_timeout = 600 # seconds.

      driver = Selenium::WebDriver.for(
          :remote,
          url: hub_url,
          http_client: client,
          desired_capabilities: capabilities
      )

      @driver = driver

      # Detects if the file being used for import is local
      # enables the use of local files in sauce labs for file import
      @driver.file_detector = lambda do |args|
        str = args.first.to_s
        str if File.exist?(str)
      end
    end

    protected

    # used when Hub connected to Node
    def hub_url
      ENV.fetch('SELENIUM_HUB_URL')
    end

    def capabilities
      Selenium::WebDriver::Remote::Capabilities.public_send(browser_type.to_sym)
    end

    private

    # used to setup client for selenium hub
    def client
      @client ||= Selenium::WebDriver::Remote::Http::Default.new
    end

    # Returns the value of attribute browser type
    def browser_type
      ENV.fetch('BROWSER').downcase
    end
  end
end
