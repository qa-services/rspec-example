module Config
  # Module for allure spec helper conguration
  module AllureConfig
    def build_path
      ENV.fetch('BUILD_PATH', 'default')
    end

    # Common configurations used for reporting services
    def allure_config
      AllureRSpec.configure do |config|
        config.output_dir = 'tmp/allure_' + build_path
        config.clean_dir = false
        config.logging_level = Logger::ERROR
      end
    end

    # Setting up allure for reporting
    def allure_screenshot
      RSpec.configure do |config|
        config.include AllureRSpec::Adaptor
        config.after(:each) do |example|
          rescue_standard_error do
            if example.exception && @browser
              rescue_standard_error do
                example.attach_file(
                    'screenshot', File.new(
                    @browser.save_screenshot(
                        file: 'tmp/allure_' + build_path + "/#{UUID.new.generate}.png"
                    )
                )
                )
              end
            end
          end
        end
      end
    end

    # Rescues exception dependent on ENV['RESCUE_EXCEPTION'] being present
    def rescue_standard_error
      yield
    rescue StandardError => e
      if ENV['RESCUE_EXCEPTION']
        nil
      else
        raise e
      end
    end
  end
end
