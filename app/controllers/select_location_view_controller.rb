# Falling into the MassiveViewController anti-pattern :(
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
    map_view_controller.snap_to_user_location
  end

  def searchableLocationTableViewController(controller, didSelectLocation: location)
    @location = location

    # Update map view with location
    if location.isCurrentLocation
      map_view_controller.snap_to_user_location
    else
      map_view_controller.snap_to_coordinate(location.placemark.coordinate)
    end

    # Update delegate's location
    unless delegate.nil? || @location.nil?
      delegate.selectLocationViewController self, didSelectLocation: @location
    end
  end

  def selectableRadiusMapViewController(controller, didChangeRadius: radius)
    unless delegate.nil?
      delegate.selectLocationViewController self, didChangeRadius: radius
    end
  end
end