require_relative './home_page'
require_relative '../components/text_box'

module Pages
  class ContactPage < HomePage

    def name
      element = @browser.find_element(css: '[data-qa=contact-name]')
      Components::TextBox.new(element)
    end

    def email
      element = @browser.find_element(css: '[data-qa=contact-email]')
      Components::TextBox.new(element)
    end

    def message
      element = @browser.find_element(css: '[data-qa=contact-message]')
      Components::TextBox.new(element)
    end

    def submit
      @browser.find_element(css: '#submit-btn')
    end
  end
end