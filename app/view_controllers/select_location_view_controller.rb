class SelectLocationViewController < UIViewController
  attr_accessor :top_container
  attr_accessor :bottom_container
  attr_accessor :map_view_controller
  attr_accessor :locations
  attr_accessor :delegate

  def loadView
    super

    view_origin = navigationController.toolbar.frame.size.height
    view_height = view.frame.size.height - view_origin
    view_width  = view.frame.size.width

    self.top_container    = UIView.alloc.initWithFrame [[         0,      view_origin ],
                                                        [ view_width, view_height / 2 ]]

    self.bottom_container = UIView.alloc.initWithFrame [[ 0, view_height / 2 + view_origin],
                                                        [ view_width, view_height / 2 ]]


    view.addSubview top_container
    view.addSubview bottom_container

    view.backgroundColor = UIColor.lightGrayColor
  end

  def viewDidLoad
    super

    init_table
    init_map
    init_location_manager
  end

  def init_table
    table_view_controller = SearchableLocationTableViewController.alloc
      .initWithNibName('SearchableLocationTableViewController', bundle: nil)

    table_view_controller.delegate = self

    table_view_controller.view.frame = [[0, 0], [top_container.frame.size.width,
                                                 top_container.frame.size.height]]
    
    self.locations = []

    top_container.addSubview table_view_controller.view
    addChildViewController(table_view_controller)
    table_view_controller.didMoveToParentViewController self
  end

  def init_map
    self.map_view_controller = SelectableRadiusMapViewController.new
    map_view_controller.delegate = self

    map_view_controller.view.frame = [[0, 0], [bottom_container.frame.size.width,
                                               bottom_container.frame.size.height]]

    bottom_container.addSubview(map_view_controller.view)

    addChildViewController(map_view_controller)
    map_view_controller.didMoveToParentViewController self
    # map_view_controller.snap_to_user_location
  end

  def init_location_manager
    @location_manager = CLLocationManager.new
    @location_manager.delegate = self
    @location_manager.distanceFilter = KCLDistanceFilterNone
    @location_manager.desiredAccuracy = KCLLocationAccuracyBest
    update_location_to_current
  end

  def locationManager(manager, didUpdateToLocation: new_location, fromLocation: old_location)
    @block.call(new_location)
    stop_updating_location
  end

  def stop_updating_location
    @location_manager.stopUpdatingLocation
    @block = Proc.new {|location| }
  end

  def searchableLocationTableViewController(controller, didSelectLocation: location)
    self.location = location
  end

  def get_current_location(&block)
    @location_manager.requestAlwaysAuthorization
    @location_manager.startUpdatingLocation
    @block = block if block
  end

  def notify_location_selected
    unless delegate.nil? || location.nil?
      delegate.selectLocationViewController self, didSelectLocation: location
    end
  end

  def selectableRadiusMapViewController(controller, didChangeCoordinate: coordinate)
    update_location_coordinate(coordinate)
  end

  def selectableRadiusMapViewController(controller, didChangeRadius: radius)
    unless delegate.nil?
      delegate.selectLocationViewController self, didChangeRadius: radius
    end
  end

  def update_location_coordinate(coordinate)
    @geocoder ||= CLGeocoder.new

    if coordinate.is_a? CLLocationCoordinate2D
      coordinate = CLLocation.alloc.initWithLatitude(coordinate.latitude, longitude: coordinate.longitude)
    end

    @geocoder.reverseGeocodeLocation(coordinate, completionHandler: ->(placemarks, error){
      if error
        placemark = MKPlacemark.alloc.initWithCoordinate coordinate.coordinate,
                                      addressDictionary: nil
      else
        placemark = placemarks.first
      end

      NSLog(coordinate.coordinate.latitude.to_s)
      NSLog(coordinate.coordinate.longitude.to_s)

      @location = MKMapItem.alloc.initWithPlacemark(placemark)

      NSLog(@location.placemark.coordinate.latitude.to_s)
      NSLog(@location.placemark.coordinate.longitude.to_s)

      map_view_controller.snap_to(@location.placemark.coordinate)
      notify_location_selected
    })
  end

  def update_location_to_current
    get_current_location do |result|
      update_location_coordinate(result)
    end
  end

private

  def location=(location)
    if location.isCurrentLocation
      update_location_to_current
    else

      @location = location

      # Update map view with location
      map_view_controller.snap_to(location.placemark.coordinate)

      notify_location_selected
    end
  end

  def location
    @location
  end
end