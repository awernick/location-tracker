// Generated by IB v0.7.2 gem. Do not edit it manually
// Run `rake ib:open` to refresh

#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@interface AppDelegate: UIResponder <UIApplicationDelegate>
@end

@interface AddLocationViewController: UIViewController
-(IBAction) viewDidLoad;

@end

@interface LocationController: UIViewController
-(IBAction) viewDidLoad;
-(IBAction) init_nav;
-(IBAction) init_table;
-(IBAction) right_buttons;
-(IBAction) nav_left_button;
-(IBAction) nav_right_button;
-(IBAction) supportedInterfaceOrientations;
-(IBAction) viewWillLayoutSubviews;
-(IBAction) didRotateFromInterfaceOrientation:(id) from_interface_orientation;

@end

@interface LocationDetailViewController: UIViewController
-(IBAction) viewDidLoad;
-(IBAction) initWithLocation:(id) location;

@end

@interface SearchableLocationTableViewController: UIViewController

@property IBOutlet UISearchBar * search_bar;
@property IBOutlet UITableView * table_view;

-(IBAction) viewDidLoad;

@end

@interface SelectLocationViewController: UIViewController
-(IBAction) loadView;
-(IBAction) viewDidLoad;
-(IBAction) init_table;
-(IBAction) init_map;
-(IBAction) viewDidUnload;

@end

@interface SelectableRadiusMapViewController: UIViewController
-(IBAction) loadView;
-(IBAction) update_location_marker:(id) coordinate;
-(IBAction) snap_to_coordinate:(id) coordinate;
-(IBAction) snap_to_user_location;
-(IBAction) radius;
-(IBAction) map_view;
-(IBAction) selector_manager;

@end

@interface Annotation: NSObject
-(IBAction) coordinate;
-(IBAction) subtitle;
-(IBAction) title;

@end

@interface Location: NSObject
-(IBAction) load;
-(IBAction) save;

@end

@interface UIViewStyler: NSObject
@end

@interface ApplicationStylesheet: RubyMotionQuery::Stylesheet
-(IBAction) application_setup;
-(IBAction) standard_button:(id) st;
-(IBAction) standard_label:(id) st;

@end

@interface LocationControllerStylesheet: ApplicationStylesheet
-(IBAction) setup;
-(IBAction) root_view:(id) st;
-(IBAction) table_view:(id) st;
-(IBAction) hello_world:(id) st;

@end

@interface LocationTableViewCellStylesheet: ApplicationStylesheet
-(IBAction) location_cell:(id) st;

@end

@interface LocationTableViewCell: SWTableViewCell
@end
