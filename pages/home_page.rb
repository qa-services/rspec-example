
module Pages
  class HomePage < BasePage
    def menu
      @browser.find_element(css: '#site-nav')
    end

    def contact
      menu.find_element(css: 'a[href$=contact]')
    end

    def go_to_contact
      contact.click
    end
  end
end