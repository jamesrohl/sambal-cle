module Positioning

  def visit page_class, &block
    on page_class, true, &block
  end

  def on page_class, visit=false, &block
    @current_page = page_class.new @browser, visit
    block.call @current_page if block
    @current_page
  end
  alias on_page on

  def wait_until(timeout=30, message=nil, &block)
    Object::Watir::Wait.until(timeout, message, &block)
  end

end