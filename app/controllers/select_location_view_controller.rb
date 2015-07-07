class SelectLocationViewController < UIViewController
  attr_accessor :map_view
  attr_accessor :locations

  Annotation = Class.new do
    def coordinate; @coordinate; end
    def subtitle;   @subtitle;   end
    def title;      @title;      end

    def initWithCoordinates(coordinate, title: title, subTitle: subtitle)
      @coordinate = coordinate
      @title = title
      @subtitle = subtitle

      self
    end
  end

  def viewDidLoad
    super

    view.backgroundColor = UIColor.lightGrayColor

    init_table
    init_map
  end

  def init_table
    table_view = UITableView.alloc.initWithFrame( CGRectMake(0, 0, view.frame.size.width, 
                                                             view.frame.size.height / 2))

    table_view.dataSource = locations
    table_view.delegate   = self
    
    locations = []

    view.addSubview table_view
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
  end

  def tableView(tableView, numberOfRowsInSection: section )
    locations.count
  end

  def init_map
    view_width  = view.frame.size.width
    view_height = view.frame.size.height
    map_view = MKMapView.alloc.initWithFrame [[         0,  view_height / 2],
                                              [ view_width, view_height / 2 ]]

    map_view.mapType = ::MKMapTypeStandard
    map_view.showsBuildings = true
    map_view.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth

    map_view.when_pressed do |recognizer|
      touch_point = recognizer.locationInView(map_view)
      coordinate = map_view.convertPoint touch_point, toCoordinateFromView: map_view
      annotation = Annotation.alloc.initWithCoordinates(coordinate, title: 'hello', subTitle: 'test')
      map_view.addAnnotation(annotation)
    end                                                   

    view.addSubview(map_view)
  end

  def current_location_clicked
    BW::Location.get_once(purpose: 'Center map based on current location') do |result|
      map_region = MKCoordinateRegionMake(result.coordinate, [0.05, 0.05])
      map_view.showsUserLocation = true
      map_view.setRegion(map_region)
    end
  end

  # TODO: Refactor pin logic to this method
  def add_pin_to_map(coordinate, annotation = nil)
  end

  def viewDidUnload
    # map_view = nil
  end
end