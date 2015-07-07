module LocationTracker
  class LocationController < UIViewController

    def viewDidLoad
      super

      # Sets a top of 0 to be below the navigation control, it's best not to do this
      # self.edgesForExtendedLayout = UIRectEdgeNone
      Location.load
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
          add_location_controller = SelectLocationViewController.alloc.init
          navigationController.pushViewController(add_location_controller, animated: true)
        end
      end
    end

    def init_table
      tableView = UITableView.alloc.initWithFrame(self.view.bounds)
      tableView.dataSource = self
      tableView.delegate = self
      rmq(tableView).apply_style :table_view
      self.view.addSubview tableView
    end

    def tableView(tableView, didSelectRowAtIndexPath: indexPath)
      location_detail = LocationDetailViewController.alloc.initWithLocation @data[indexPath.row]
      self.navigationController.pushViewController(location_detail, animated: true)
    end

    def tableView(tableView, numberOfRowsInSection: section)
      @data.count
    end

    def tableView(tableView, cellForRowAtIndexPath: indexPath)
      @identifier ||= 'CELL_IDENTIFIER'

      cell = 
        tableView.dequeueReusableCellWithIdentifier(@identifier) || 
        SWTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, 
                                            reuseIdentifier: @identifier)

      cell.tap do |cell|
        cell.textLabel.text = @data[indexPath.row].label
        cell.rightUtilityButtons = right_buttons
      end
    end

    def right_buttons
      buttons = []
      buttons.tap do|buttons|
        buttons.sw_addUtilityButtonWithColor(UIColor.grayColor,
                                             title: 'Disable')
        buttons.sw_addUtilityButtonWithColor(UIColor.redColor,
                                             title: 'Delete')

      end
    end

    def nav_left_button
      puts 'Left button'
    end

    def nav_right_button
      puts 'Right button'
    end

    # Remove these if you are only supporting portrait
    def supportedInterfaceOrientations
      UIInterfaceOrientationMaskAll
    end
    def willAnimateRotationToInterfaceOrientation(orientation, duration: duration)
      # Called before rotation
      rmq.all.reapply_styles
    end
    def viewWillLayoutSubviews
      # Called anytime the frame changes, including rotation, and when the in-call status bar shows or hides
      #
      # If you need to reapply styles during rotation, do it here instead
      # of willAnimateRotationToInterfaceOrientation, however make sure your styles only apply the layout when
      # called multiple times
    end
    def didRotateFromInterfaceOrientation(from_interface_orientation)
      # Called after rotation
    end
  end
end


__END__

# You don't have to reapply styles to all UIViews, if you want to optimize,
# another way to do it is tag the views you need to restyle in your stylesheet,
# then only reapply the tagged views, like so:
def logo(st)
  st.frame = {t: 10, w: 200, h: 96}
  st.centered = :horizontal
  st.image = image.resource('logo')
  st.tag(:reapply_style)
end

# Then in willAnimateRotationToInterfaceOrientation
rmq(:reapply_style).reapply_styles


