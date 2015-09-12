//
//  GeofenceController.swift
//  waittimes-ios
//
//  Created by Alan Wernick on 9/11/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

import Foundation
import CoreLocation

class GeofenceController: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
    }
    
    func track(bridge: Bridge){
        if CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
            println("Can monitor locations")
        } else {
            println("Can't monitor locations")
            return
        }
        
        for fence in bridge.fences {
            var coordinate = CLLocationCoordinate2D(latitude: fence.latitude, longitude: fence.longitude)
            var region = CLCircularRegion(center: coordinate, radius: 30.0, identifier: fence.name)
            locationManager.startMonitoringForRegion(region)
            println("Requesting monitoring for region \(region.identifier)")
        }
    }
    
    func remove(bridge: Bridge){
        for fence in bridge.fences {
            for region in locationManager.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion {
                    if circularRegion.identifier == fence.name {
                        println("Stopped tracking region \(circularRegion.identifier)")
                        locationManager.stopMonitoringForRegion(circularRegion)
                    }
                }
            }
        }
    }
    
    /**
    * Confirm region monitoring has started
    */
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        println("Tracking region with identifier \(region.identifier)")
        
        // Delay region state update.
        // Necessary since CoreLocation takes a while to setup each region.
        // Without it, the location manager will throw an error.
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            manager.requestStateForRegion(region)
        })
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        println("We are \(state.rawValue) the region \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("\(error): we have failed...")
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        println("I failed at monitoring region \(region.identifier)): \(error)")
    }
}