import SwiftyJSON
import MagicalRecord

@objc(Geofence)
public class Geofence: _Geofence {

	// Custom logic goes here.
    class func createWithJSON(json: JSON, context: NSManagedObjectContext) -> Geofence {
        var fence = Geofence.MR_createEntityInContext(context)
        fence.name = json["name"].stringValue
        fence.longitude = json["longitude"].numberValue
        fence.latitude = json["latitude"].numberValue
        return fence
    }
}
