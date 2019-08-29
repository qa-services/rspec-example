def initialize_browser
  case driver_type
  when 'REMOTE'
    driver = Lib::RemoteDriver.new.driver
  when 'LOCAL'
    @download_directory = generate_download_path

    download_prefs = {
        prompt_for_download: false,
        default_directory: @download_directory
    }

    plugin_prefs = {
        always_open_pdf_externally: true
    }

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_preference(:download, download_prefs)
    options.add_preference(:plugins, plugin_prefs) if ENV['DISABLE_PDF_VIEWER'] == 'true'
    options.add_argument('disable-infobars')
    options.add_argument('--incognito')
    driver = Selenium::WebDriver.for :chrome, options: options

    @download_directory
  else
    nil
  end

  Lib::Browser.new(driver)
end


# Sets a unique file download path
def generate_download_path
  File.join(Dir.pwd, 'data/downloads', UUID.new.generate)
end