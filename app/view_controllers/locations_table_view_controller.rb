class LocationsTableViewController < UIViewController
  attr_accessor :table_view

  def init
    super
   
    @locations_repository = Location::Repository
    @visits_repository = Visit::Repository

    Location.all.each do |location|
      @locations_repository.save(location)
    end

    Visit.all.each do |visit|
      @visits_repository.save(visit) do |remote_visit|
        if visit.id != remote_visit && Visit.find(visit.id)
          # Visit::Repository.delete(visit)
          visit.destroy
        end
        
        visit.update_attributes(remote_visit.to_h)
        visit.save
      end
    end

    @data = Location

    init_nav
    init_table
    
    @location_manager_delegate = LocationManagerDelegate.new

    # Load all locations
    @locations_repository.all do |locations|
      locations.each do |location|
        location.save
        @location_manager_delegate.register_location(location)
      end
      table_view.reloadData
    end

    # Load all visits
    @visits_repository.all do |visits|
      visits.each(&:save)
    end
    
    self
  end

  def viewDidLoad
    super
    rmq.stylesheet = LocationControllerStylesheet
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
    @data.size
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    @identifier ||= 'CELL_IDENTIFIER'

    cell =
    tableView.dequeueReusableCellWithIdentifier(@identifier) ||
    UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault,
      reuseIdentifier: @identifier)

    cell.tap do |cell|
      cell.textLabel.text = @data[indexPath.row].name
      # cell.rightUtilityButtons = right_buttons
    end
  end

  def tableView(tableView, editActionsForRowAtIndexPath: indexPath)
    edit_btn = UITableViewRowAction.rowActionWithStyle( UITableViewRowActionStyleNormal, title: "Edit", handler: -> action, indexPath {
      location_detail = EditLocationViewController.alloc.initWithLocation @data[indexPath.row]
      location_detail.delegate = self
      self.navigationController.pushViewController(location_detail, animated: true)
    })

    delete_btn = UITableViewRowAction.rowActionWithStyle(UITableViewRowActionStyleNormal, title: "Delete", handler: -> action, indexPath {
      location = @data[indexPath.row]
      location.destroy

      @locations_repository.delete(location)
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
      buttons.sw_addUtilityButtonWithColor(UIColor.grayColor, title: 'Disable')
      buttons.sw_addUtilityButtonWithColor(UIColor.redColor, title: 'Delete')
    end
  end

  def present_new_location_modal
    modal_controller = EditLocationViewController.alloc.initWithStyle UITableViewStyleGrouped
    modal_controller.delegate = self
    modal_navbar = UINavigationController.alloc.initWithRootViewController(modal_controller)

    navigationController.presentViewController(modal_navbar, animated: true, completion: nil)
  end

  def editLocationViewController(controller, didEditLocation: location)
    @locations_repository.save(location) do |new_location|
      # Erase location if it has been persisted before but not in repository
      if location.id != new_location && Location.find(location.id)
        location.destroy
      end

      location.update_attributes(new_location.to_h)
      location.save
      location.reload

      table_view.reloadData

      @location_manager_delegate.register_location(location)
    end
  end

  def location_manager
    return @location_manager_delegate.location_manager
  end
end
