//
//  Bridge.swift
//  waittimes-ios
//
//  Created by Victor Fernandez on 9/3/15.
//  Copyright (c) 2015 WaitTimes, Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class BridgePreview {
    let id: Int
    let bridgeNumber: Int
    let name: String
    let lat: Double
    let lon: Double
    let jsonData: JSON
    
    init(json: JSON){
        self.id = json["id"].intValue
        self.name = json["name"].stringValue
        self.lat = json["latitude"].doubleValue
        self.lon = json["longitude"].doubleValue
        self.bridgeNumber = json["bridge_number"].intValue
        self.jsonData = json
    }
}