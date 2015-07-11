class SelectableRadiusMapViewController < UIViewController
  attr_accessor :delegate

  def loadView
    self.map_view             = MKMapView.new
    map_view.mapType          = ::MKMapTypeStandard
    map_view.delegate         = self
    map_view.showsBuildings   = true
    map_view.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth

    self.selector_manager = 
      DBMapSelectorManager.alloc.initWithMapView(map_view)

    selector_manager.circleRadiusMin = 25
    selector_manager.circleRadiusMax = 500
    selector_manager.circleRadius = 25
    selector_manager.shouldLongPressGesture = true
    selector_manager.fillColor = UIColor.clearColor
    selector_manager.strokeColor = UIColor.redColor
    selector_manager.applySelectorSettings
    selector_manager.delegate = self

    self.radius = selector_manager.circleRadius
    self.view = map_view
  end

  # def update_location_marker(coordinate)
  #   @location = map_view.annotations.last || Annotation.new
  #   @location.coordinate = coordinate

  #   selector_manager.circleCoordinate = coordinate

  #   snap_to_coordinate(coordinate)
  # end

  def snap_to_coordinate(coordinate)
    # Update annotations coordinate
    @location = map_view.annotations.last || Annotation.new
    @location.coordinate = coordinate

    # Update radius selector's location
    selector_manager.circleCoordinate = coordinate

    # Zoom into coordinate
    region = MKCoordinateRegionMakeWithDistance(coordinate, 20.0, 20.0);
    map_view.setRegion region, animated: true
  end

  def snap_to_user_location
    BW::Location.get_once(purpose: 'Center map on user location') do |result|
      if result.is_a? CLLocation
        snap_to_coordinate(result.coordinate)
      else
        p result[:error]
      end
    end
  end

  #### MKMapViewDelegate

  def mapView(mapView, viewForAnnotation: annotation) 
    selector_manager.mapView mapView, viewForAnnotation: annotation
  end

  def mapView(mapView, annotationView: annotationView, 
              didChangeDragState: newState, fromOldState: oldState)

    selector_manager.mapView mapView, 
                             annotationView:     annotationView, 
                             didChangeDragState: newState, 
                             fromOldState:       oldState
  end

  def mapView(mapView, rendererForOverlay: overlay) 
    selector_manager.mapView mapView, rendererForOverlay: overlay
  end

  def mapView(mapView, regionDidChangeAnimated: animated)
    selector_manager.mapView mapView, regionDidChangeAnimated: animated
  end

  #### DBMapSelectorManagerDelegate 

  def mapSelectorManager(mapSelectorManager, didChangeRadius: radius)
    p radius
    unless delegate.nil?
      delegate.selectableRadiusMapViewController self, didChangeRadius: radius
    end
    # p self.radius
  end

protected
  
  def radius
    @radius
  end

  def radius=(radius)
    @radius = radius
  end

private

  def map_view
    @map_view 
  end

  def selector_manager
    @selector_manager
  end

  def map_view=(map_view)
    @map_view = map_view
  end

  def selector_manager=(selector_manager)
    @selector_manager = selector_manager
  end
end