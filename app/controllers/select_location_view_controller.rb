# Falling into the MassiveViewController anti-pattern :(
class SelectLocationViewController < UIViewController
  attr_accessor :map_view, :locations, :geocoder, :top_container, :bottom_container

  def loadView
    super

    view_height = view.frame.size.height
    view_width  = view.frame.size.width

    self.top_container    = UIView.alloc.initWithFrame [[         0,                0 ],
                                                        [ view_width, view_height / 2 ]]

    self.bottom_container = UIView.alloc.initWithFrame [[         0,  view_height / 2 ],
                                                        [ view_width, view_height / 2 ]]

    # top_container.alignTopEdgeWithView       view, predicate:nil                       
    # bottom_container.alignBottomEdgeWithView view, predicate: nil

    view.addSubview top_container
    view.addSubview bottom_container

    view.backgroundColor = UIColor.lightGrayColor
  end

  def viewDidLoad
    super

    init_table
    init_map
  end

  def init_table
    table_view = UITableView.alloc.initWithFrame(CGRectMake(0, 0, view.frame.size.width,
                                                                  view.frame.size.height))

    table_view.dataSource = locations
    table_view.delegate   = self
    
    self.locations = []

    top_container.addSubview table_view
  end

  def init_map
    map_view_controller = SelectableRadiusMapViewController.new

    map_view_controller.view.frame = [[0, 0,], [bottom_container.frame.size.width,
                                                bottom_container.frame.size.height]]

    bottom_container.addSubview(map_view_controller.view)
    addChildViewController(map_view_controller)
    map_view_controller.didMoveToParentViewController self

    BW::Location.get_once(purpose: 'Center map based on current location') do |result|
      map_view_controller.updateLocationMarker result.coordinate
    end
  end

    # self.map_view = SelectableRadiusMapView.alloc.initWithFrame [[         0,  view_height / 2 ],
    #                                                              [ view_width, view_height / 2 ]]


    # map_view.when_pressed do |recognizer|
    #   touch_point = recognizer.locationInView(map_view)
    #   coordinate = map_view.convertPoint touch_point, toCoordinateFromView: map_view

    #   map_selector_manager.circleCoordinate = coordinate
    #   map_selector_manager.circleRadius = 3000
    #   map_selector_manager.fillColor = UIColor.clearColor
    #   map_selector_manager.strokeColor = UIColor.redColor
    #   map_selector_manager.applySelectorSettings

    #   self.geocoder ||= CLGeocoder.alloc.init

    #   annotation = Annotation.alloc.init
    #   annotation.coordinate = coordinate

    #   location = CLLocation.alloc.initWithLatitude coordinate.latitude, longitude: coordinate.longitude

    #   geocoder.reverseGeocodeLocation(location, completionHandler: lambda do |placemarks, error|
    #     break unless error.nil? && placemarks.count > 0
    #     placemark = placemarks.objectAtIndex(0)
    #     map_view.removeAnnotation(annotation)
    #     annotation.title = "#{placemark.locality}"
    #     annotation.subtitle = "Country = #{placemark.country} \nPostal Code = #{placemark.postalCode} \n"
    #     map_view.addAnnotation(annotation)
    #   end)

    #   # circle = MKCircle.circleWithCenterCoordinate coordinate, radius:fence_distance
    #   # map_view.addOverlay(circle)

    #   map_view.addAnnotation(annotation)
    # end


    # view.addSubview(map_view)
  # end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
  end

  def tableView(tableView, numberOfRowsInSection: section )
    locations.count
  end


  # def current_location_clicked
  #   BW::Location.get_once(purpose: 'Center map based on current location') do |result|
  #     map_region = MKCoordinateRegionMake(result.coordinate, [0.05, 0.05])
  #     map_view.showsUserLocation = true
  #     map_view.setRegion(map_region)
  #   end
  # end

  # TODO: Refactor pin logic to this method
  def add_pin_to_map(coordinate, annotation = nil)
  end

  def viewDidUnload
    # map_view = nil
  end
end