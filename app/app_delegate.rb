module LocationTracker
  class AppDelegate
    attr_reader :window

    def application(application, didFinishLaunchingWithOptions:launchOptions)
      @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

      location_controller = LocationsTableViewController.new
      
      @window.rootViewController = UINavigationController.alloc.initWithRootViewController(location_controller)
      @window.makeKeyAndVisible
      true
    end

    # Remove this if you are only supporting portrait
    def application(application, willChangeStatusBarOrientation: new_orientation, duration: duration)
      # Manually set RMQ's orientation before the device is actually oriented
      # So that we can do stuff like style views before the rotation begins
      rmq.device.orientation = new_orientation
    end
  end
end
