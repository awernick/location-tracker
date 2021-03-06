class EditLocationViewController < UITableViewController
  attr_accessor :delegate
  
  SECTIONS = {name: 0, location: 1}

  def initWithLocation(location)
    @location = location

    initWithStyle(UITableViewStyleGrouped)
  end

  def loadView
    super

    init_navbar

    # Setup name
    @nameCell = UITableViewCell.new
    @nameCell.backgroundColor = '#88FFFFFF'.to_color
    @nameText = UITextField.alloc.initWithFrame CGRectInset(@nameCell.contentView.bounds, 15, 0)
    @nameText.placeholder = 'Name'
    @nameCell.addSubview(@nameText)

    # Setup location selector
    @locationCell = UITableViewCell.alloc.initWithStyle UITableViewCellStyleSubtitle, 
                                          reuseIdentifier: 'CELL_IDENTIFIER'

    @locationCell.textLabel.text = 'Location'
    @locationCell.backgroundColor = '#88FFFFFF'.to_color
    @locationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator
 
    if @location
      @nameText.text = @location.name
      @locationCell.detailTextLabel.text = @location.address
    else
      @location = Location.new
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
    when SECTIONS[:name]
      return @nameCell
    when SECTIONS[:location]
      return @locationCell
    end
  end

  def tableView(table_view, titleForHeaderInSection: section)
    SECTIONS.key(section) unless section == SECTIONS[:location]
  end

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    if index_path.section == SECTIONS[:location]
      if @location.coordinate.nil?
        select_location_controller = SelectLocationViewController.alloc.init
      else
        select_location_controller = SelectLocationViewController.alloc.initWithLocation(@location)
      end
      select_location_controller.delegate = self
      navigationController.pushViewController select_location_controller, animated: true
    end
  end

  def selectLocationViewController(controller, didSelectLocation: location)
    @location.tap do |tracked_location|
      tracked_location.address = location.name
      tracked_location.longitude = location.placemark.coordinate.longitude
      tracked_location.latitude = location.placemark.coordinate.latitude
    end
    
    @locationCell.detailTextLabel.text = location.name
  end

  def selectLocationViewController(controller, didChangeRadius: radius)
    @location.radius = radius
  end

  def save_location_and_close
    if @nameText.text.empty? # Use NSNotifcations or KVO instead
      @location.name = @locationCell.detailTextLabel.text
    else
      @location.name = @nameText.text
    end

    delegate.editLocationViewController(self, didEditLocation: @location)
    close
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