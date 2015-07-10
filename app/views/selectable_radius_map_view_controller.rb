class SelectableRadiusMapViewController < UIViewController

  def loadView
    self.map_view             = MKMapView.new
    map_view.mapType          = ::MKMapTypeStandard
    map_view.delegate         = self
    map_view.showsBuildings   = true
    map_view.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth

    self.selector_manager = 
      DBMapSelectorManager.alloc.initWithMapView(map_view)

    selector_manager.circleRadiusMin = 50
    selector_manager.circleRadiusMax = 500
    selector_manager.circleRadius = 50
    selector_manager.shouldLongPressGesture = true
    selector_manager.fillColor = UIColor.clearColor
    selector_manager.strokeColor = UIColor.redColor
    selector_manager.applySelectorSettings
    selector_manager.delegate = self

    self.view = map_view
  end

  # def viewDidLoad
  #   @location.coordinate = CLLocationCoordinate2DMake(0.0, 0.0)
  #   map_view.addAnnotation(@location)
  # end

  def updateLocationMarker(coordinate)
    @location = map_view.annotations.last || Annotation.new
    @location.coordinate = coordinate

    selector_manager.circleCoordinate = coordinate

    snapToLocation(coordinate)
  end

  def snapToLocation(coordinate)
    region = MKCoordinateRegionMakeWithDistance(coordinate, 100.0, 100.0);
    map_view.setRegion region, animated: true
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
    self.radius = radius
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