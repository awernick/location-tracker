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

class ViewController: UIViewController {
  
  var mapView: MGLMapView!

    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      mapView = MGLMapView(frame: view.bounds)
      mapView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
      
      
      let url = NSURL(string: "http://192.168.31.152/api/v1/bridges")
//      let url = NSURL(string: "http://waittimes.io/api/v1/bridges")
      let session = NSURLSession.sharedSession()
      
      let task = session.dataTaskWithURL(url!, completionHandler: { (data, response, error)in
        
        let json = JSON(data: data)
        var mapLong = json["bridges"][0]["location"][0].double!
        var mapLat = json["bridges"][0]["location"][1].double!
        self.mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: mapLat, longitude: mapLong), zoomLevel: 15, animated: true)
        
        
        
        self.view.addSubview(self.mapView)
        
        
      })
      
      task.resume()
    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

