class LocationsTableViewController < UIViewController
  attr_accessor :location_manager
  attr_accessor :table_view

  def init
    super

    @location_manager = CLLocationManager.new
    @location_manager.delegate = self
    @location_manager.desiredAccuracy = KCLLocationAccuracyBest
    @location_manager.requestAlwaysAuthorization()

    self
  end

  def viewWillAppear(flag)
    super

    unless table_view.nil?
      table_view.reloadData
      Location.save
    end
  end

  def viewDidLoad
    super

    # Sets a top of 0 to be below the navigation control, it's best not to do this
    # self.edgesForExtendedLayout = UIRectEdgeNone
    @visits_controller = VisitsController.new($json_client)
    @data  = Location.all

    rmq.stylesheet = LocationControllerStylesheet
    init_nav
    init_table
    rmq(self.view).apply_style :root_view
  end

  def init_nav
    self.title = 'Locations'

    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = BW::UIBarButtonItem.system(:action)

      nav.rightBarButtonItem = BW::UIBarButtonItem.system(:add) do
        present_new_location_modal
      end
    end
  end

  def init_table
    self.table_view = UITableView.alloc.initWithFrame(self.view.bounds)
    table_view.dataSource = self
    table_view.delegate = self
    rmq(table_view).apply_style :table_view
    self.view.addSubview table_view
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    # location_detail = CalendarViewController.new
    
    location_detail = EditLocationViewController.alloc.initWithLocation @data[indexPath.row]
    location_detail.delegate = self
    self.navigationController.pushViewController(location_detail, animated: true)
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @data.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @identifier ||= 'CELL_IDENTIFIER'

    cell =
    tableView.dequeueReusableCellWithIdentifier(@identifier) ||
    UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault,
      reuseIdentifier: @identifier)

    cell.tap do |cell|
      cell.textLabel.text = @data[indexPath.row].label
      # cell.rightUtilityButtons = right_buttons
    end
  end

  def tableView(tableView, editActionsForRowAtIndexPath: indexPath)
    p 'called'
    edit_btn = UITableViewRowAction.rowActionWithStyle( UITableViewRowActionStyleNormal, title: "Edit", handler: -> action, indexPath {
      location_detail = EditLocationViewController.alloc.initWithLocation @data[indexPath.row]
      location_detail.delegate = self
      self.navigationController.pushViewController(location_detail, animated: true)
    })

    delete_btn = UITableViewRowAction.rowActionWithStyle(UITableViewRowActionStyleNormal, title: "Delete", handler: -> action, indexPath {
      location = @data[indexPath.row]
      location.delete
      @data.delete_at(indexPath.row)

      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationFade)
    })

    delete_btn.backgroundColor = UIColor.redColor

    [delete_btn, edit_btn]
  end

  def tableView(table_view, canEditRowAtIndexPath: index_path)
    true
  end

  def tableView(table_view, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
  end

  def right_buttons
    buttons = []
    buttons.tap do |buttons|
      buttons.sw_addUtilityButtonWithColor(UIColor.grayColor,
       title: 'Disable')
      buttons.sw_addUtilityButtonWithColor(UIColor.redColor,
       title: 'Delete')
    end
  end

  def present_new_location_modal
    modal_controller = EditLocationViewController.alloc.initWithStyle UITableViewStyleGrouped
    modal_controller.delegate = self
    modal_navbar = UINavigationController.alloc.initWithRootViewController(modal_controller)

    navigationController.presentViewController(modal_navbar, animated: true, completion: nil)
  end

  ## Region Handling

  def editLocationViewController(controller, didEditLocation: location)
    register_location(location)
  end

  def register_location(location)
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

   def locationManager(manager, didDetermineState: state, forRegion: region)
    NSLog("Region: #{region.center.latitude} #{region.center.longitude}")
    NSLog("State: #{state}")
    handleRegionEvent(region, state)
  end

  def locationManager(manager, didEnterRegion: region)
    NSLog("ENTER REGION!")
    handleRegionEvent(region, CLRegionStateInside)
  end

  def locationManager(manager, didExitRegion: region)
    NSLog("EXIT REGION!")
    handleRegionEvent(region, CLRegionStateOutside)
  end

  def handleRegionEvent(region, state)
    p 'Handling region event'
    NSLog('Handling region event')
    
    @visits_controller.handle_region_event(region, state)

    if state == CLRegionStateInside
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Enter Event'
      notification.alertBody = "#{region.identifier}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)

    elsif state == CLRegionStateOutside
      notification = UILocalNotification.new
      notification.alertTitle = 'Region Exit Event'
      notification.alertBody = "#{region.identifier}"
      UIApplication.sharedApplication.presentLocalNotificationNow(notification)
    end
  end

  def locationManager(manager, didStartMonitoringForRegion: region)
    NSLog('Started Monitoring')
    p 'Started monitoring'

    manager.requestStateForRegion(region)
  end

  def locationManager(manager, monitoringDidFailForRegion: region, withError: error)
    NSLog("Location Manager failed to monitor the region #{region.identifier} with the following error: ")
    NSLog(error.to_s)
  end

  def locationManager(manager, didFailWithError: error)
    NSLog("Location manager failed with the following error:")
    NSLog(error.to_s)
  end
end
