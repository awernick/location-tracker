class EditLocationViewController < UITableViewController
  @@counter = 0
  SECTIONS = {label: 0, location: 1}

  def initWithLocation(location)
    @location = location

    initWithStyle(UITableViewStyleGrouped)
  end

  def loadView
    super

    init_navbar

    # Setup label
    @labelCell = UITableViewCell.new
    @labelCell.backgroundColor = '#88FFFFFF'.to_color
    @labelText = UITextField.alloc.initWithFrame CGRectInset(@labelCell.contentView.bounds, 15, 0)
    @labelText.placeholder = 'First Name'
    @labelCell.addSubview(@labelText)

    # Setup location selector
    @locationCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, 
                                          reuseIdentifier: 'CELL_IDENTIFIER'

    @locationCell.textLabel.text = 'Location'
    @locationCell.backgroundColor = '#88FFFFFF'.to_color
    @locationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    @location_manager = CLLocationManager.new
    @location_manager.delegate = self
    @location_manager.desiredAccuracy = KCLLocationAccuracyBest
    @location_manager.requestAlwaysAuthorization()

    if @location
      @labelText.text = @location.label
      @locationCell.detailTextLabel.text = @location.name
    else
      @location = LocationTracker::Location.new
    end
  end

  def init_navbar
    # Set title
    if is_modal?
      self.title = 'New Location'
    else
      self.title = 'Details'
    end

    # Setup buttons
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = BW::UIBarButtonItem.system(:cancel) do
        close
      end if is_modal?

      nav.rightBarButtonItem = BW::UIBarButtonItem.system(:done) do
        save_location_and_close
      end
    end
  end

  def numberOfSectionsInTableView(table_view)
    2
  end

  def tableView(table_view, numberOfRowsInSection: section)
    1
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    case index_path.section
    when SECTIONS[:label]
      return @labelCell
    when SECTIONS[:location]
      return @locationCell
    end
  end

  def tableView(table_view, titleForHeaderInSection: section)
    SECTIONS.key(section) unless section == SECTIONS[:location]
  end

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    if index_path.section == SECTIONS[:location]
      select_location_controller = SelectLocationViewController.alloc.init
      select_location_controller.delegate = self
      navigationController.pushViewController select_location_controller, animated: true
    end
  end

  def selectLocationViewController(controller, didSelectLocation: location)
    @location.tap do |tracked_location|
      tracked_location.name = location.name
      tracked_location.longitude = location.placemark.coordinate.longitude
      tracked_location.latitude = location.placemark.coordinate.latitude
    end
    
    @locationCell.detailTextLabel.text = location.name
  end

  def selectLocationViewController(controller, didChangeRadius: radius)
    @location.radius = radius
  end

  def save_location_and_close
    if @labelText.text.empty? # Use NSNotifcations or KVO instead
      @location.label = @locationCell.detailTextLabel.text
    else
      @location.label = @labelText.text
    end

    register_location(@location)

    @location.save

    close
  end

  def register_location(location)
    if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion)
      p 'can monitor'
      NSLog("can monitor")
    end

    if location.radius > @location_manager.maximumRegionMonitoringDistance
      location.radius = @location_manager.maximumRegionMonitoringDistance
    end

   p 'location register'
   NSLog('longitude register')
   # NSLog(location)
   # NSLog(location.coordinate.latitude)
   # NSLog(location.coordinate.longitude)
   p 'location register done'

   # Start monitoring the location
   region = CLCircularRegion.alloc.initWithCenter location.coordinate,
                                          radius: location.radius, 
                                      identifier: location.label
   # NSLog(region.center.latitude)
   # NSLog(region.center.longitude)

   @location_manager.startMonitoringForRegion(region, desiredAccuracy: KCLLocationAccuracyBest)
   # @location_manager.requestStateForRegion(region)
   @location_manager.startUpdatingLocation()
  end

  # def locationManager(manager, didUpdateToLocation: newLocation, fromLocation: oldLocation)
  #   NSLog("Location: #{newLocation.coordinate.latitude} #{newLocation.coordinate.longitude}")
  # end

  def locationManager(manager, didDetermineState: state, forRegion: region)
    NSLog("Region: #{region.center.latitude} #{region.center.longitude}")
    NSLog("Update: #{region} #{state}")
    if state == 1
      handleRegionEvent(region)
    end
  end

  def locationManager(manager, didEnterRegion: region)
    NSLog("ENTER REGION!")
    handleRegionEvent(region)
  end

  def locationManager(manager, didExitRegion: region)
    NSLog("EXIT REGION!")
    handleRegionEvent(region)
  end

  def handleRegionEvent(region)
    alert = UIAlertView.alloc.initWithTitle('Region event', message: "#{region.identifier}", delegate: nil, cancelButtonTitle: 'OK', otherButtonTitles: nil)
    alert.show
    p 'region event for: ' + region.identifier
  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    p 'Started monitoring'
    NSLog("started monitor")
    NSLog("Regions Monitored: #{@location_manager.monitoredRegions.count}")
    p region.identifier
    p region.radius
    p region.center
  end

  def locationManager(manager, monitoringDidFailForRegion: region, withError: error)
    @@counter += 1
    NSLog('called')
    NSLog(region.identifier)
    NSLog("Counter: #{@@counter}")

    p "Monitoring failed for" + region.identifier
    NSLog(error.to_s)
    NSLog("error location")
    NSLog("Regions Monitored: #{@location_manager.monitoredRegions.count}")

    # @location_manager.stopMonitoringForRegion(region)
    # NSLog(@location_manager.monitoredRegions.to_s)
    # for monitored in @location_manager.monitoredRegions
    #   NSLog(@location_manager.monitoredRegions.to_s)
    #   @location_manager.stopMonitoringForRegion(monitored)
    # end
  end
 
  def locationManager(manager, didFailWithError: error)
    p "Location Manager failed with the following error: " + error 
    NSLog("Location manager failed with error")
  end

  def is_modal?
    navigationController.presentingViewController &&
      navigationController.presentingViewController.presentedViewController == navigationController
  end

  def close
    if is_modal?
      dismissViewControllerAnimated(true, completion: nil)
    else
      navigationController.popViewControllerAnimated(true)
    end
  end

  # Necessary monkey patch. For some strange reason, iPhone6 
  # and larger devices use CGPoint instead of CLLLocationCoorindate2D
  # as the coordinate property for MKMapItem's placemark
  CGPoint.class_eval do
    alias_method  :latitude,  :y
    alias_method  :longitude, :x
  end
end