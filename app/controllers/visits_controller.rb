class VisitsController
  class << self
    def handle_region_event(region, state)
      Location.all.to_a.select{|location| location == region.center}.each do |location|
        if state == CLRegionStateInside
          start_visit(location)
        elsif state == CLRegionStateOutside
          end_visit(location)
        end
      end
    end

    # Region Enter
    def start_visit(location)
      # Handle duplicate enter region event
      close_location_visits(location)
      
      visit = Visit.create(location_id: location.id)
      visit.reload

      Visit::Repository.save(visit) do |remote_visit|
        if visit.id != remote_visit.id && Visit.find(visit.id)
          visit.destroy
        end

        visit.update_attributes(remote_visit.to_h)
        visit.save
        visit.reload
      end
    end

    # Region Exit
    def end_visit(location)
      close_location_visits(location)
    end

    # Get all open visits
    def open_visits(location = nil)
      open_visits = Visit.all.to_a.select(&:open)
      open_visits = open_visits.select{|visit| visit.location_id == location.id} unless location.nil?
      open_visits
    end

    def close_location_visits(location, &block)
      open_visits(location).each do |visit|
        visit.open = false
        visit.end_time = Time.now
        block.call(visit) if block
        Visit::Repository.save(visit) do |remote_visit|
          if visit.id != remote_visit && Visit.find(visit.id)
            visit.destroy
          end

          visit.update_attributes(remote_visit.to_h)
          visit.save
        end
      end
    end
  end
end
