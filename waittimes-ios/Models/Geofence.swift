import SwiftyJSON

@objc(Geofence)
public class Geofence: _Geofence {

	// Custom logic goes here.
    class func createWithJSON(json: JSON) -> Geofence {
        var fence = Geofence.MR_createEntity()
        fence.name = json["name"].stringValue
        fence.longitude = json["longitude"].numberValue
        fence.latitude = json["latitude"].numberValue
        return fence
    }
}
