class VisitsController

  def initialize(json_client)
    @json_client = json_client
    Location.load
  end

  # Region Enter
  def start_visit(location)
    # Handle duplicate enter region event
    close_location_visits(location) { |visit| visit.end_time = visit.start_time }

    visit = location.visits.new
    visit.location_id = location._id

    @json_client.post("visits", visit.to_h) do |result|
      if result.error
        NSLog(result.error.to_s)
      else
        visit._id = result.object['_id']
        visit.location_id = location.id
        visit.save!

        NSLog("saved visit: #{visit._id} with location_id: #{visit.location_id}")
      end
    end
  end

  # Region Exit
  def end_visit(location)
    close_location_visits(location)
  end

  # Get all open visits
  def open_visits(location = nil)
    Visit.load
    open_visits = Visit.where(:open).eq(true)
    open_visits = open_visits.and(:location).eq(location) unless location.nil?
    open_visits
  end

  def close_location_visits(location)
    open_visits(location).each do |visit|
      visit.open = false
      visit.end_time = Time.now
      visit.location_id = location._id
      yield visit

      @json_client.put("visits/#{visit._id}", visit.to_h) do |result|
        if result.error
          NSLog(result.error.to_s)
        else
          NSLog("updated visit: #{visit._id}")
        end
      end
      
      visit.location_id = location.id
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
end