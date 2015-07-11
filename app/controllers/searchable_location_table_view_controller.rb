# TODO: 
# 1. Remove duplicate locations (time to use CS knowledge! :D)
# 2. Check that table is reloaded appropriately after text edit
class SearchableLocationTableViewController < UIViewController
  extend IB

  outlet :search_bar, UISearchBar
  outlet :table_view, UITableView

  attr_accessor :search_controller
  attr_accessor :locations
  attr_accessor :delegate

  attr_reader   :current_location_map_item

  def viewDidLoad
    
    # Set up the table view
    table_view.delegate = self
    table_view.dataSource = self

    # Set up the search bar
    search_bar.delegate = self

    @current_location_map_item = MKMapItem.mapItemForCurrentLocation
    init_locations_with_current
  end

  def init_locations_with_current
    self.locations = [@current_location_map_item]
  end

  def numberOfSectionsInTableView(tableView)
    return 1
  end

  def tableView(tableView, numberOfRowsInSection: section)
    locations.count
  end

  def display_nearby_locations(search_text)
    init_locations_with_current

    request = MKLocalSearchRequest.new
    request.naturalLanguageQuery = search_text
    search = MKLocalSearch.alloc.initWithRequest(request)
    search.startWithCompletionHandler lambda { |response, error|

      unless response.nil? 
        locations << response.mapItems
        locations.flatten!
      end

      table_view.reloadData()
    }
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    search_bar.endEditing(true)
    tableView.deselectRowAtIndexPath indexPath, animated: true

    if delegate
      # Trust that the delegate implements the protocol (might add check later)
      delegate.searchableLocationTableViewController(self, didSelectLocation: locations[indexPath.row] )
    end
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @identifier ||= 'CELL_IDENTIFIER'

    # Protect yourself from nil current location bruh
    return if locations[indexPath.row].nil?

    cell = 
      tableView.dequeueReusableCellWithIdentifier(@identifier) || 
      UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, 
                                          reuseIdentifier: @identifier)

    cell.tap do |cell|
      placemark = locations[indexPath.row].placemark
 
      if placemark.nil? and locations[indexPath.row].isCurrentLocation
        location_string = 'Current Location'
      else
        location_string = placemark.title
        location_string = "Lat: #{placemark.coordinate.latitude}\
                           Long: #{placemark.coordinate.longitude}" if placemark.title.empty?
      end

      cell.textLabel.text = location_string
    end
  end

  def searchBar(searchBar, textDidChange: searchText)
    display_nearby_locations(searchBar.text)
  end
end