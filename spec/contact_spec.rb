describe 'Contact form:' do

  it 'submit with invalid email', :negative, :contact do
    Given 'I navigate to the qa-services home page' do
      @browser.navigate_to base_url
      @contact_page = Pages::ContactPage.new(@browser)
    end

    When 'I fill in contact form with incorrect email' do
      @contact_page.name.text = 'Automation rspec'
      @contact_page.email.text = 'automation'
      @contact_page.message.text = 'Automation rspec test'
    end

    And 'I submit form' do
      @contact_page.submit.click
    end

    Then 'I expect to see an incorrect email error' do
      @browser.wait_until { @contact_page.email.error? }
      expect(@contact_page.email.error?).to be_truthy
    end
  end

  it 'submit correct form' do
    Given 'I navigate to the qa-services page' do
      @browser.navigate_to base_url
      @contact_page = Pages::ContactPage.new(@browser)
    end

    When 'I fill in contact form' do
      @contact_page.name.text = 'Automation rspec'
      @contact_page.email.text = 'automation@rspec.com'
      @contact_page.message.text = 'Automation rspec test'
    end

    And 'I submit form' do
      @contact_page.submit.click
    end

    Then 'I expect to see success message' do
      @browser.wait_until { @contact_page.submit.text.include? 'MESSAGE SENT' }
    end
  end
end