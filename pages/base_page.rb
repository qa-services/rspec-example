module Pages
  class BasePage
    attr_reader :browser

    def initialize(browser)
      @browser = browser
    end
  end
end