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
    notify_radius_change(25)

    self.radius = selector_manager.circleRadius
    self.view = map_view
  end

  def snap_to(coordinate, radius = 25)
    # Update annotations coordinate
    @location = map_view.annotations.last || Annotation.new
    @location.coordinate = coordinate

    # Update radius selector's location
    selector_manager.circleCoordinate = coordinate
    selector_manager.circleRadius = radius

    # Zoom into coordinate
    region = MKCoordinateRegionMakeWithDistance(coordinate, 20.0, 20.0);
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
    notify_radius_change(radius)
  end

  def mapSelectorManager(mapSelectorManager, didChangeCoordinate: coordinate)
    delegate.selectableRadiusMapViewController self, didChangeCoordinate: coordinate
  end

  def notify_radius_change(radius)
    unless delegate.nil?
      delegate.selectableRadiusMapViewController self, didChangeRadius: radius
    end
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