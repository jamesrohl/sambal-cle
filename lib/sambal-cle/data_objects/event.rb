class EventObject

  include Positioning
  include Utilities
  include Workflows

  attr_accessor :title, :month, :day, :year, :start_hour, :start_minute,
                :start_meridian, :duration_hours, :duration_minutes, :end_hour,
                :end_minute, :end_meridian, :message, :site, :link, :message_html

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :title=>random_alphanums,
        :month=>in_15_minutes[:month_str],
        :day=>in_15_minutes[:day],
        :year=>in_15_minutes[:year],
        :start_hour=>in_15_minutes[:hour],
        :start_minute=>in_15_minutes[:minute],
        :start_meridian=>in_15_minutes[:meridian],
        :message=>random_multiline(400,20, :alpha)
    }
    options = defaults.merge(opts)

    set_options(options)
    requires @site
  end

  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    calendar unless @browser.title=~/Calendar$/
    on Calendar do |cal|
      cal.add_event
    end
    on AddEditEvent do |add_event|
      add_event.enter_source_text add_event.editor, @message
      add_event.title.set @title
      add_event.month.select @month
      add_event.day.select @day
      add_event.year.select @year
      add_event.start_hour.select @start_hour
      add_event.start_minute.select @start_minute
      add_event.start_meridian.select @start_meridian
      if @end_hour == nil && @duration_hours == nil
        @duration_hours = add_event.hours.value
        @duration_minutes = add_event.minutes.value
        @end_hour = add_event.end_hour.value
        @end_minute = add_event.end_minute.value
        @end_meridian = add_event.end_meridian.value
      elsif @end_hour == nil
        # Todo: Add this later
      elsif @duration_hours == nil
        # Todo: Add this later
      end
      add_event.save_event
    end
    on Calendar do |cal|
      @link = cal.event_href @title
    end
  end

  def view
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    calendar unless @browser.title=~/Calendar$/
    on Calendar do |cal|
      cal.open_event @title
    end
    on EventDetail do |event|
      @message_html = event.message_html
      # TODO: Lots of stuff to add here...
      # ...event.details...
    end
  end

end