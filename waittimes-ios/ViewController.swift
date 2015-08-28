//
//  ViewController.swift
//  waittimes-ios
//
//  Created by Guillermo Vargas on 8/27/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Mapbox

class ViewController: UIViewController, MGLMapViewDelegate {
  
  var mapView: MGLMapView!

    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      
      mapView = MGLMapView(frame: view.bounds)
      
      mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      mapView.userTrackingMode = .Follow
      mapView.delegate = self
      
      
      let url = NSURL(string: "http://192.168.31.152/api/v1/bridges")
//      let url = NSURL(string: "http://waittimes.io/api/v1/bridges")
      let session = NSURLSession.sharedSession()
      
      let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error)in
        
        let json = JSON(data: data)
        var mapLong = json["bridges"][0]["location"][0].double!
        var mapLat = json["bridges"][0]["location"][1].double!
        var bridgeName = json["bridges"][0]["name"].stringValue
        var bridgeNumber = json["bridges"][0]["bridge_number"].stringValue
        self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong), zoomLevel: 15, animated: true)
        
        let hello = MGLPointAnnotation()
        hello.coordinate = CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong)
        hello.title = bridgeName
        hello.subtitle = bridgeNumber
        
        self.mapView.addAnnotation(hello)
        
        
        
        
        self.view.addSubview(self.mapView)
        
        
      })
      
      
      task.resume()
      
    }
  
  func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
    return true
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
//    Delcare annotation point and set its coordinates, title, and subtitles.
    
//    let point = MGLPointAnnotation()
//    point.coordinate = CLLocationCoordinate2DMake(31.889655855870153 , -106.99258804321289)
//    point.title = "Bridge of the Americas"
//    point.subtitle = "The first bridge of waittimes"
//    
//    self.mapView.addAnnotation(point)
  }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

