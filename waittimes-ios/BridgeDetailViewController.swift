//
//  BridgeDetailViewController.swift
//  waittimes-ios
//
//  Created by Victor Fernandez on 9/4/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Mapbox

class BridgeDetailViewController: UIViewController, MGLMapViewDelegate {
    @IBOutlet weak var bridgeNameLabel: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bridgeNumberLabel: UILabel!
    
    var mapView: MGLMapView!
    var bridge: Bridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set title
        bridgeNameLabel.text = bridge.name
        bridgeNumberLabel.text = bridge.bridgeNumber()
        
        //setup the mapview
        mapView = MGLMapView(frame: view.bounds)
        
        mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        mapView.userTrackingMode = .Follow
        mapView.delegate = self
        
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
        //setup the center coordinate
        self.mapView.setCenterCoordinate(
            CLLocationCoordinate2D(latitude: bridge.latitudeDouble(), longitude: bridge.longitudeDouble()),
            zoomLevel: 15,
            animated: true
        )
        //add marker
        let point = MGLPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: bridge.latitudeDouble(), longitude: bridge.longitudeDouble())
        point.title = self.bridge.name
        point.subtitle = self.bridge.bridgeNumber()
        self.mapView.addAnnotation(point)
    }
    /**
    * loadGeofencesClicked
    *
    * whenever the 'load geofences' is click this methods will
    * be called with the uibutton as sender.
    */
    @IBAction func loadGeofencesClicked(sender: AnyObject) {
        NSLog("load geofences for bridge with id=%@", bridge.bridge_number!)
    }
}
