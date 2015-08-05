class VisitsController

  def self.instance
    Dispatch.once { @instance = new }
    @instance
  end

  def initialize
    Location.load
  end

  # Region Enter
  def start_visit(location)
    # Handle duplicate enter region event
    close_location_visits(location) { |visit| visit.end_time = visit.start_time }

    visit = location.visits.create({})
    visit.save
  end

  # Region Exit
  def end_visit(location)
    close_location_visits(location)
  end

  # Get all open visits
  def open_visits(location = nil)
    open_visits = Visit.where(:open).eq(true)
    open_visits = open_visits.and(:location).eq(location) unless location.nil?
    open_visits
  end

  def close_location_visits(location, &block)
    open_visits(location).each do |visit|
      visit.open = false
      visit.end_time = Time.now
      block.call(visit) if block
      visit.save
    end
  end

  def handle_region_event(region, state)
    Location.find{|location| location == region.center}.all.each do |location|
      if state == CLRegionStateInside
        start_visit(location)
      elsif state == CLRegionStateOutside
        end_visit(location)
      end
    end
  end
  
  private_class_method :new
end