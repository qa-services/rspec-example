module Components
  class TextArea
    attr_reader :element

    def initialize(element)
      @element = element
    end

    def input
      element.find_element(css: 'input')
    end

    def error
      element.find_element(css: '.help-block li')
    end

    def error?
      element.attribute('class').include? 'has_error'
    end

    def text=(value)
      input.send_keys value
    end

    def text
      input.attribute('value')
    end

    def clear
      input.clear
    end
  end
end