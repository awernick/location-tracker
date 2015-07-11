class EditLocationViewController < UITableViewController
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
    if @labelText.text.empty?
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
    end

    if location.radius > @location_manager.maximumRegionMonitoringDistance
      location.radius = @location_manager.maximumRegionMonitoringDistance
    end
 
   # Start monitoring the location
   region = CLCircularRegion.alloc.initWithCenter location.coordinate,
                                          radius: location.radius, 
                                      identifier: location.label

   @location_manager.startMonitoringForRegion(region)

  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    p 'Started monitoring'
    p region.identifier
    p region.radius
    p region.center
  end

  def locationManager(manager, monitoringDidFailForRegion: region, withError: error)
    p "Monitoring failed for" + region.identifier
  end
 
  def locationManager(manager, didFailWithError: error)
    p "Location Manager failed with the following error: " + error 
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