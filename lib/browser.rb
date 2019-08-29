# frozen_string_literal: true
require 'selenium-webdriver'

module Lib
  class Browser
    attr_accessor :driver

    def initialize(driver)
      @driver = driver
      $driver_session = driver

      # Attempts to resize the browser window
      window_resize
    end

    def window_resize
      # move browser to top left corner of primary screen
      driver.manage.window.move_to(0, 0)
      # maximise browser to screen size
      screen_width = @driver.execute_script('return screen.width;')
      screen_height = @driver.execute_script('return screen.height;')
      driver.manage.window.resize_to(screen_width, screen_height)
    rescue Selenium::WebDriver::Error::UnknownError
      # handle chromedriver issue
      # https://bugs.chromium.org/p/chromedriver/issues/detail?id=1901
      puts 'Unable to resize window due to chromedriver issue'.colorize(:red)
    end

    def navigate_to(url)
      driver.navigate.to url
      wait_for_ajax
    end

    def navigate_back
      driver.navigate.back
      wait_for_ajax
    end

    def close_browser
      driver.close
    end

    def current_url
      driver.current_url
    end

    # used to rescue selenium error NoSuchElementError
    # Use in page object when we want to test an element id not displayed
    # when it does not exist on the DOM
    # @example
    # def print_delivery_action
    #   browser.no_such_element_rescue do
    #     element = actions_container.find_element(css: '[data-role="print-delivery"]')
    #     S1SeleniumFramework::Components::Content::CarbonRoleContent.new(element)
    #   end
    # end
    # @return [Object] displayed?: false
    def no_such_element_rescue
      yield
    rescue Selenium::WebDriver::Error::NoSuchElementError
      OpenStruct.new(displayed?: false)
    end

    # finder methods
    #
    # used to find an element
    # @example
    #   browser.find_element(locator)
    # @return [element]
    def find_element(locator)
      retry_exception(exception: Selenium::WebDriver::Error::StaleElementReferenceError, retries: 10) do
        driver.find_element(locator)
      end
    end

    # used to find an element
    # @example
    #   browser.find_elements(locator)
    # @return [Array] elements
    def find_elements(locator)
      driver.find_elements(locator)
    end

    # used to find an element by value
    # @example
    #   browser.find_element_by_value(locator, value)
    # @return [element]
    def find_element_by_value(locator, value)
      @browser.find_elements(locator).select { |el| el.attribute('value') == value }.first
    end

    # Bring into view methods
    #
    # scrolls element into view
    # @example
    #   browser.move_to_element(element)
    def move_to_element(element)
      driver.execute_script('arguments[0].scrollIntoView(true)', element)
    end

    # Bring into view methods
    #
    # scrolls element into centre of screen
    # @example
    #   browser.show_element_in_centre(element)
    def show_element_in_centre(element)
      driver.execute_script("arguments[0].scrollIntoView({block: 'center'});", element)
    end

    # Bring into view methods
    #
    # Mouse over to elements
    # @example
    #   browser.mouse_over_element(element)
    def mouse_over_element(element)
      driver.action.move_to(element).perform
    end

    # used to move to top of page
    # @example
    #   browser.show_top_of_page
    def show_top_of_page
      driver.execute_script('window.scrollTo(0,0)')
    end

    # used to move to bottom of page
    # @example
    #   browser.show_bottom_of_page
    def show_bottom_of_page
      driver.execute_script('window.scrollTo(0,document.body.scrollHeight)')
    end

    # page refresh
    def page_refresh
      driver.navigate.refresh
    end

    # Browser tabs
    # @example
    #   browser.tabs
    # @return [Array]
    def tabs
      driver.window_handles
    end

    # Wait for browser tabs
    # @example
    #   browser.wait_for_tab_count(2)
    # @return [Array]
    def wait_for_tab_count(tab_count)
      wait_until { tabs.count == tab_count }
    end

    # used to move to a tab using tab index
    # @example
    #   browser.move_to_tab(1)
    def move_to_tab(tab)
      # index is zero based, remove one
      tab -= 1
      driver.switch_to.window(tabs[tab])
    end

    # Method to wait for an elements data-state to match an expected state
    # @example
    #   browser.wait_for_data_state(new_contact_dialog, "open")
    # @return [boolean] true/false
    # @param component
    # @param expected_state
    # @param timeout (Defaults to: 10)
    def wait_for_data_state(component, expected_state, timeout: 10)
      retry_exception(exception: Selenium::WebDriver::Error::StaleElementReferenceError, retries: 3) do
        wait(timeout).until { component.data_state == expected_state }
      end
    end

    # This is used to wait for element to load
    # this is run behind using java script
    # @example
    #   browser.wait_for_ajax return window.jQuery != undefined
    def wait_for_ajax(timeout: 20)
      wait(timeout).until do
        driver.execute_script('return jQuery.active == 0')
        sleep 1
      end
    rescue StandardError
      'wait_for_ajax: jQuery not active'
    end

    # This is used to wait untill action is performed
    # @example
    #   browser.wait_until(timeout: 10) { @edit_sales_invoice_page.sales_invoice_total_net.text == '300.00' }
    def wait_until(timeout: 10)
      wait(timeout).until do
        yield
      end
    end

    def wait_until_click(element, timeout: 10)
      wait(timeout).until do
        begin
          element.click
          true
        rescue Selenium::WebDriver::Error::ElementClickInterceptedError
          false
        end
      end
    end

    # used wait for element to disapear
    # @example
    #   wait_for_element_to_disappear { @currency_settings_page.form.save.element }
    #
    #   wait_for_element_to_disappear do
    #     @currency_settings_page.form.save.element
    #   end
    def wait_for_element_to_disappear(max_counter: 300)
      counter = 0

      element = rescue_exceptions { yield }

      if element
        while rescue_exceptions { yield.displayed? } && counter < max_counter
          counter += 1
          sleep 0.01
        end
      end
    end

    # used to raise the required error messages
    # for when an element is not found
    # @example
    #   rescue_exceptions { @browser.find_element(locator).displayed? }
    # @return [Boolean] true/false
    def rescue_exceptions
      yield
    rescue Selenium::WebDriver::Error::NoSuchElementError
      false
    rescue Selenium::WebDriver::Error::StaleElementReferenceError
      false
    end

    # Retry exeception
    # Retries the method execution if exception is hit
    # @example
    #   retry_exception(exception: Selenium::WebDriver::Error::StaleElementReferenceError) do
    #     wait(5).until { element.displayed? }
    #   end
    # @param exception (defaults to: nil)
    # @param retries (defaults to: 3)
    def retry_exception(exception: nil, retries: 3)
      yield
    rescue exception
      sleep 0.01
      retry unless (retries -= 1).zero?
    end

    # used to verify if the element is displayed
    # should only be used when it is needed to return false instead of standard selenium error
    # use expect(element.displayed?).to be true instead
    # @example
    #   browser.element_is_visibe?(css: 'some_element')
    # @return [Boolean] true/false
    def element_is_visible?(locator = {})
      rescue_exceptions { driver.find_element(locator).displayed? }
    end


    # used to save a screen shot
    # @example
    #   @browser.save_screenshot("tmp/allure_default/#{UUID.new.generate}.png")
    # @param file (defaults to: nil)
    def save_screenshot(file: nil)
      driver.save_screenshot(File.join(Dir.pwd, file))
    end

    # This is used to refresh the data until a given condition is met
    # @example
    #   browser.refresh_until_condition_true(proc { ms1_settings_page_obj.user_profile_link.displayed? }, timeout: 30)
    def refresh_until_condition_true(condition, timeout: 30, wait: 1)
      count ||= 0

      until condition.call
        driver.navigate.refresh
        sleep wait
        count += 1
        next unless count >= timeout
        raise 'Data refresh timed out'
      end
    end
  end
end
