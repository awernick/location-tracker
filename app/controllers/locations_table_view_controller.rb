module LocationTracker
  class LocationsTableViewController < UIViewController
    attr_accessor :location_manager

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
      location_detail = EditLocationViewController.alloc.initWithLocation @data[indexPath.row]
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
      buttons.tap do |buttons|
        buttons.sw_addUtilityButtonWithColor(UIColor.grayColor,
                                             title: 'Disable')
        buttons.sw_addUtilityButtonWithColor(UIColor.redColor,
                                             title: 'Delete')

      end
    end

    def present_new_location_modal
      modal_controller = EditLocationViewController.alloc.initWithStyle UITableViewStyleGrouped
      modal_navbar = UINavigationController.alloc.initWithRootViewController(modal_controller)



      navigationController.presentViewController(modal_navbar, animated: true, completion: nil)
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

  private
    def table_view=(table_view)
      @table_view = table_view
    end

    def table_view
      @table_view
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
