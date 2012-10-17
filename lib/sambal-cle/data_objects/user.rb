class UserObject

  include PageHelper
  include Utilities
  include Randomizers
  include DateMakers
  include Workflows
  
  attr_accessor :id, :first_name, :last_name, :password, :email, :type,
                :created_by, :creation_date, :modified_by, :modified_date, :internal_id
  
  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        :id=>random_alphanums,
        :first_name=>random_alphanums,
        :last_name=>random_alphanums,
        :email=>random_email,
        :type=>"Student",
        :password=>random_alphanums,
    }
    options = defaults.merge(opts)

    @id=options[:id]
    @first_name=options[:first_name]
    @last_name=options[:last_name]
    @email=options[:email]
    @type=options[:type]
    @password=options[:password]
  end
    
  def create
    # TODO
  end
    
  def edit opts={}
    # TODO
  end
    
  def view
    # TODO
  end
    
  def delete
    # TODO
  end

  def exist?
    # TODO
  end

  def log_in
    if logged_in?
      # do nothing
    else # see if we're on the login screen
      if @browser.frame(:id, "ifrm").text_field(:id, "eid").present?
        userlogin
      else # Log the current user out, then log in
        logout
        userlogin
      end
    end
  end
  alias login log_in

  def logged_in?
    welcome=@browser.span(:class=>"welcome")
    if welcome.present?
      welcome.text=~/#{@first_name}/ ? true : false
    else
      return false
    end
  end

  def log_out
    @browser.link(:text=>"Logout").click
  end

  private

  def userlogin
    on Login do |page|
      page.login_with @id, @password
    end
  end

end
    
      