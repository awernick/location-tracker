module LocationTracker
  class AppDelegate
    attr_reader :window

    def application(application, didFinishLaunchingWithOptions:launchOptions)
      application.registerUserNotificationSettings(UIUserNotificationSettings.settingsForTypes(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound, categories:nil))
      @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      
      # Initialize Logger
      sink =  Device.simulator? ? Logger::StandardLogger.new : Logger::DeviceLogger.new
      $logger = Logger.new(sink)
      
      # Config Remote DAOs
      repo_config = {
        site: ENV['SERVER_ADDRESS'],
        client: AFMotion::JSON
      }
      
      Location::Repository.config do |repo| 
        repo.site   = repo_config[:site]
        repo.client = repo_config[:client]
      end

      Visit::Repository.config do |repo|
        repo.site   = repo_config[:site]
        repo.client = repo_config[:client]
      end
      
      # Start root view controller
      location_controller = LocationsTableViewController.new
      @location_manager = location_controller.location_manager
      
      @window.rootViewController = UINavigationController.alloc.
                                     initWithRootViewController(location_controller)

      @window.makeKeyAndVisible

      true
    end

    def applicationWillEnterForeground(application)
    end

    def applicationDidEnterBackground(application)
      if CLLocationManager.significantLocationChangeMonitoringAvailable
        $logger << 'significant location monitoring started'

    		@location_manager.stopUpdatingLocation
    		@location_manager.startMonitoringSignificantLocationChanges
    	else
    		$logger << "Significant location change monitoring is not available."
    	end
    end

    def applicationDidBecomeActive(application)
      $logger << 'became active'

      if CLLocationManager.significantLocationChangeMonitoringAvailable
        @location_manager.stopMonitoringSignificantLocationChanges
		    @location_manager.startUpdatingLocation
      end
    end
  end
end
