class CalendarViewController < UIViewController
  def init
    @data = []
    
    self
  end

  def viewDidLoad
    super

    view = CKCalendarView.new
    view.delegate = self
    view.dataSource = self

    self.view = view; 
    view.release
  end

  def calendarView(calendarView, willSelectDate: date)
  end

  def calendarView(calendarView, didSelectDate: date)
  end

  def calendarView(calendarView, didSelectEvent: event)
  end

  def calendarView(calendarView, eventsForDate: date)
    return @data
  end
end