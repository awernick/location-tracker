import SwiftyJSON
import MagicalRecord
import Foundation

@objc(Geofence)
public class Geofence: _Geofence {
    func updateWithJSON(bridge: Bridge!, json: JSON){
        self.longitude = json["longitud"].numberValue
        self.latitude = json["latitude"].numberValue
        self.radius = json["radius"].numberValue
        self.bridge = bridge
    }
    /**
    * createWithJSON
    *
    * create a new geofence with the given bridge object and
    * json passed in which should contain a name, latitude, 
    * longitude, and a bridge
    */
    class func createWithJSON(bridge: Bridge!, json: JSON) -> Geofence {
        var fence = Geofence.MR_createEntity()
        fence.name = json["name"].stringValue
        fence.longitude = json["longitude"].numberValue
        fence.latitude = json["latitude"].numberValue
        fence.radius = json["radius"].numberValue
        fence.bridge = bridge
        return fence
    }
    /**
    * findAndUpdateChangeablesOrCreateWithJSON
    *
    * Tries to find an object with the name if found then that
    * object will be update else a new object (geofence) is created
    * and that object is returned. Caller must provide a Bridge to
    * set in the one relationship
    */

    class func findAndUpdateChangeablesOrCreateWithJSON(bridge: Bridge, json: JSON) -> Geofence {
        var fences = bridge.fencesSet()
        var predicate = NSPredicate(format: "name == %@", json["name"].stringValue)
        var foundFences = fences.filteredSetUsingPredicate(predicate)
        if foundFences.count > 0 {
            var fence = foundFences.first as! Geofence
            fence.updateWithJSON(bridge, json: json)
            return fence
        }else{
            return createWithJSON(bridge, json: json)
        }
    }
}
