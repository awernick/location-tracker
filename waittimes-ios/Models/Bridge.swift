
import SwiftyJSON
import CoreData
import MagicalRecord

@objc(Bridge)
public class Bridge: _Bridge {
    /**
    * Instance Functions
    */
    func bridgeNumber() -> String {
        return self.bridge_number!.stringValue
    }
    
    func longitudeDouble() -> Double {
        return Double(self.longitude!)
    }
    
    func latitudeDouble() -> Double {
        return Double(self.latitude!)
    }
    /**
    * Class Functions
    */
    class func createWithJSON(json: JSON) -> Bridge{
        return Bridge.createWithJSON(json, context: nil)
    }
    
    class func createWithJSON(json: JSON, context: NSManagedObjectContext?) -> Bridge {
        var bridge: Bridge
        if context != nil {
            bridge = Bridge.MR_createEntityInContext(context)
        }else{
            bridge = Bridge.MR_createEntity()
        }
        bridge.id = json["id"].numberValue
        bridge.name = json["name"].stringValue
        bridge.bridge_number = json["bridge_number"].numberValue
        bridge.longitude = json["longitude"].numberValue
        bridge.latitude = json["latitude"].numberValue
        var fences = NSMutableSet()
        for fence in json["fences"].arrayValue {
            var fence = Geofence.createWithJSON(fence)
            fences.addObject(fence)
        }
        bridge.addFences(fences)
        bridge.tracking = false
        return bridge
    }
    
}
