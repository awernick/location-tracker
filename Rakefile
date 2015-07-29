# -*- coding: utf-8 -*-
$:.unshift('/Library/RubyMotion/lib')
require 'motion/project/template/ios'
require 'bubble-wrap'
require 'bubble-wrap/all'
require 'bundler'
Bundler.require

# require 'bubble-wrap'

Motion::Project::App.setup do |app|

  app.name = 'location_tracker'
  app.identifier = 'com.napkin-studio.location_tracker'
  app.short_version = '0.1.0'
  app.version = app.short_version

  app.info_plist['NSLocationAlwaysUsageDescription'] = 'Description'
  app.info_plist['NSLocationWhenInUseUsageDescription'] = 'Description'

  # SDK 8 for iOS 8 and above
  # app.sdk_version = '8.2'
  # app.deployment_target = '8.0'

  # SDK 8 for iOS 7 and above
  # app.sdk_version = '8.2'
  # app.deployment_target = '7.1'

  # Or for SDK 7
  # app.sdk_version = '7.1'
  # app.deployment_target = '7.0'

  IB::RakeTask.new do |project|
  end

  app.icons = ["icon@2x.png", "icon-29@2x.png", "icon-40@2x.png", "icon-60@2x.png", "icon-76@2x.png", "icon-512@2x.png"]

  # prerendered_icon is only needed in iOS 6
  #app.prerendered_icon = true

  app.device_family = [:iphone, :ipad]
  app.interface_orientations = [:portrait, :landscape_left, :landscape_right, :portrait_upside_down]

  app.files += Dir.glob(File.join(app.project_dir, 'lib/**/*.rb'))

  # Use `rake config' to see complete project settings, here are some examples:
  #
  # app.fonts = ['Oswald-Regular.ttf', 'FontAwesome.otf'] # These go in /resources
  app.frameworks += %w[CoreLocation MapKit]
  #
  # app.vendor_project('vendor/DSLCalendarView', :static, :cflags => '-fobjc-arc') # Using arc
  #
  app.pods do
    pod 'SWTableViewCell', '~> 0.3.7'
    pod 'DBMapSelectorViewController', '~> 1.2.0'
    pod 'FLKAutoLayout', '~> 0.2.1'
  end
 
  app.development do
    # app.codesign_certificate = "iPhone Developer: Alan "
    app.codesign_certificate = "Alan Wernick"
    # app.seed_id = "7ENH393J5J"
    app.provisioning_profile = "location_tracker.mobileprovision"
    app.entitlements['application-identifier'] = app.seed_id + '.' + app.identifier
  end

  app.release do
    app.entitlements['get-task-allow'] = false
    app.codesign_certificate = 'iPhone Distribution: YOURNAME'
    app.provisioning_profile = "location_tracker.mobileprovision"
    app.seed_id = "YOUR_SEED_ID"
    app.entitlements['application-identifier'] = app.seed_id + '.' + app.identifier
    app.entitlements['keychain-access-groups'] = [ app.seed_id + '.' + app.identifier ]
  end

  # puts "Name: #{app.name}"
  # puts "Using profile: #{app.provisioning_profile}"
  # puts "Using certificate: #{app.codesign_certificate}"
end

desc "Run simulator on iPhone"
task :iphone4 do
    exec 'bundle exec rake device_name="iPhone 4s"'
end

desc "Run simulator on iPhone"
task :iphone5 do
    exec 'bundle exec rake device_name="iPhone 5"'
end

desc "Run simulator on iPhone"
task :iphone6 do
    exec 'bundle exec rake device_name="iPhone 6"'
end

desc "Run simulator in iPad Retina" 
task :retina do
    exec 'bundle exec rake device_name="iPad Retina"'
end

desc "Run simulator on iPad Air" 
task :ipad do
    exec 'bundle exec rake device_name="iPad Air"'
end
