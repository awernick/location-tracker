//
//  BridgeDetailViewController.swift
//  waittimes-ios
//
//  Created by Victor Fernandez on 9/4/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON
import Mapbox

class BridgeDetailViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet weak var bridgeNameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bridgeNumberLabel: UILabel!
    @IBOutlet weak var geofencesLabel: UILabel!
    @IBOutlet weak var trackGeofencesButton: UISwitch!
    
    var mapView: MGLMapView!
    var bridge: Bridge!
    var id: NSNumber = 0
    let geofenceController = GeofenceController()
    
    /**
    * viewDidLoad
    *
    * When the view is loaded, the map view is setup, the different labels
    * are also setup, and
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        //set title
        self.bridge = Bridge.findWithID(self.id)
        println("loaded bridge \(bridge)")
        bridgeNameLabel.text = bridge.nameString()
        bridgeNumberLabel.text = bridge.bridgeNumberString_()
        
        //setup the mapview
        mapView = MGLMapView(frame: self.bottomView.bounds)
        
        mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        mapView.userTrackingMode = .Follow
        mapView.delegate = self
        
        //set switch
        self.setGeofenceInformation(self.bridge.track())
        trackGeofencesButton.setOn(self.bridge.track(), animated: true)
        
        //add map as subview of this controllers view
        self.bottomView.addSubview(self.mapView)
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        
        return true
    }
    /**
    * viewDidAppear
    *
    * the center of the map is set as well as a marker is setup in the
    * middle denoting the bridge location.
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSLog("MapView - annotation can now show!")
        //setup the center coordinate
        self.mapView.setCenterCoordinate(
            CLLocationCoordinate2D(latitude: bridge.latitudeDouble(), longitude: bridge.longitudeDouble()),
            zoomLevel: 15,
            animated: true
        )
        
        //add marker
        let point = MGLPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: bridge.latitudeDouble(), longitude: bridge.longitudeDouble())
        point.title = self.bridge.nameString()
        point.subtitle = self.bridge.bridgeNumberString_()
        self.mapView.addAnnotation(point)
        
        //add graphical geofences
    }
    /**
    * setGeofenceInformation
    * 
    * Depending on the geofence information the some information is
    * show in the geofences label
    */
    func setGeofenceInformation(tracked: Bool){
        var geofenceInfo: NSString
        if tracked {
            var numFences = self.bridge.fencesSet().count
            geofenceInfo = NSString(format: "tracked with %d geofences", numFences)
        }else{
            geofenceInfo = NSString(format: "bridge not tracked")
        }
        self.geofencesLabel.text = String(geofenceInfo)
    }
    /**
    * loadGeofencesClicked
    *
    * whenever the 'load geofences' is click this methods will
    * be called with the uibutton as sender.
    */
    @IBAction func loadGeofencesClicked(sender: AnyObject) {
        NSLog("load geofences for bridge with id=%@", bridge.bridgeNumberString_())
    }
    /**
    *
    * whenever the switch ui button on the bridge detail view is
    * clicked the status of the bridge will be updated.
    */
    @IBAction func trackGeofences(sender: AnyObject) {
        var switchButton = sender as! UISwitch
        if switchButton.on {
            if !bridge.track() {
                NSLog("Not tracking bridge[%@] anymore", bridge.bridgeNumberString_())
                self.setGeofenceInformation(true)
                geofenceController.track(bridge)
                bridge.track(true)
            }
        }else{
            if bridge.track(){
                NSLog("Tracking bridge[%@]", bridge.bridgeNumberString_())
                self.setGeofenceInformation(false)
                geofenceController.remove(bridge)
                bridge.track(false)
            }
        }
    }
}
