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
      if location.label == region.identifier && location.radius == region.radius && location == region.center
        deregister_region(region)
      end
    end

    if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
      NSLog("Can monitor locations")
    end

    if location.radius > location_manager.maximumRegionMonitoringDistance
      location.radius = location_manager.maximumRegionMonitoringDistance
    end

    # Start monitoring the location
    region = CLCircularRegion.alloc.
      initWithCenter location.coordinate,
      radius:        location.radius,
      identifier:    location.label

    location_manager.startMonitoringForRegion(region, desiredAccuracy: KCLLocationAccuracyBest)
  end

  def deregister_region(region)
    location_manager.stopMonitoringForRegion(region)
  end

  # def locationManager(manager, didEnterRegion: region)
  #   NSLog("ENTER REGION!")
  #   p manager.to_s
  #   handleRegionEvent(manager, region, CLRegionStateInside)
  # end

  # def locationManager(manager, didExitRegion: region)
  #   NSLog("EXIT REGION!")
  #   p manager.to_s
  #   handleRegionEvent(manager, region, CLRegionStateOutside)
  # end

  def locationManager(manager, didDetermineState: state, forRegion: region)

    p 'Handling region event'
    NSLog('Handling region event')

    VisitsController.handle_region_event(region, state)

    if state == CLRegionStateInside
      NSLog("ENTER REGION!")
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Enter Event'
      notification.alertBody = "#{region.identifier}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)

    elsif state == CLRegionStateOutside
      NSLog("EXIT REGION!")
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Exit Event'
      notification.alertBody = "#{region.identifier}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)
    end
  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    NSLog('Started Monitoring')
    p 'Started monitoring'

    # Delay necessary to avoid error
    App.run_after(5){manager.requestStateForRegion(region)}
  end

  def locationManager(manager, monitoringDidFailForRegion: region, withError: error)
    NSLog("Location Manager failed to monitor the region #{region.identifier} with the following error: ")
    NSLog(error.to_s)
  end

  def locationManager(manager, didFailWithError: error)
    NSLog("Location manager failed with the following error:")
    NSLog(error.to_s)
  end

  # def editLocationViewController(controller, didEditLocation: location)
  #   register_location(location)
  # end
end