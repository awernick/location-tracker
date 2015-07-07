class AddLocationViewController < UIViewController
  attr_accessor :table_view

  def viewDidLoad
    super

    # table_view = UITableViewController.alloc.initWithFrame(view.bounds)
    #  searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    #   /*the search bar widht must be > 1, the height must be at least 44
    #   (the real size of the search bar)*/

    #       searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    #   /*contents controller is the UITableViewController, this let you to reuse
    #   the same TableViewController Delegate method used for the main table.*/

    #       searchDisplayController.delegate = self;
    #       searchDisplayController.searchResultsDataSource = self;
    #   //set the delegate = self. Previously declared in ViewController.h

    #       self.tableView.tableHeaderView = searchBar;
  end
end