class LocationManagerDelegate
  attr_reader :location_manager

  def initialize
    @location_manager = CLLocationManager.new
    @location_manager.delegate = self
    @location_manager.desiredAccuracy = KCLLocationAccuracyBest
    @location_manager.requestAlwaysAuthorization()
  end

  def register_location(location)
    location_manager.monitoredRegions.each do |region|
      if location.id == region.identifier
        deregister_region(region)
      end
    end

    if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
      $logger << "Can monitor locations"
    end

    if location.radius > location_manager.maximumRegionMonitoringDistance
      location.radius = location_manager.maximumRegionMonitoringDistance
    end

    # Start monitoring the location
    region = CLCircularRegion.alloc.
      initWithCenter location.coordinate,
      radius:        location.radius,
      identifier:    location.id

    location_manager.startMonitoringForRegion(region, desiredAccuracy: KCLLocationAccuracyBest)
  end

  def deregister_region(region)
    location_manager.stopMonitoringForRegion(region)
  end

  def locationManager(manager, didDetermineState: state, forRegion: region)
    location = Location.find(region.identifier)

    $logger << 'Handling region event'

    VisitsController.handle_region_event(region, state)

    if state == CLRegionStateInside
      $logger << 'ENTER REGION'
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Enter Event'
      notification.alertBody = "#{location.name}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)

    elsif state == CLRegionStateOutside
      $logger << "EXIT REGION!"
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Exit Event'
      notification.alertBody = "#{location.name}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)
    end
  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    $logger << 'Started Monitoring'

    # Delay necessary to avoid errors with LocationManager
    App.run_after(5){manager.requestStateForRegion(region)}
  end

  def locationManager(manager, monitoringDidFailForRegion: region, withError: error)
    $logger << "Location Manager failed to monitor the region #{region.identifier} with the following error: "
    $logger << error
  end

  def locationManager(manager, didFailWithError: error)
    $logger << "Location manager failed with the following error:"
    $logger << error
  end
end
