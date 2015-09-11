
import SwiftyJSON
import CoreData
import MagicalRecord

@objc(Bridge)
public class Bridge: _Bridge {
    /**
    * Instance Functions
    */
    func getID() -> NSNumber {
        return self.valueForKey("id") as! NSNumber
    }
    func getName() -> String {
        return self.valueForKey("name") as! String
    }
    func bridgeNumber() -> String {
        return self.valueForKey("bridge_number") as! String
    }
    
    func longitudeDouble() -> Double {
        return Double(self.valueForKey("longitude") as! NSNumber)
    }
    
    func latitudeDouble() -> Double {
        return Double(self.valueForKey("latitude") as! NSNumber)
    }
    /**
    * updateExceptUnchangeables
    *
    * updates the attributes of the bridge except those that need to be
    * keep persistenly the same
    */
    func updateExceptUnchangeables(json: JSON, context: NSManagedObjectContext){
        self.id = json["id"].numberValue
        self.name = json["name"].stringValue
        self.bridge_number = json["bridge_number"].numberValue
        self.longitude = json["longitude"].numberValue
        self.latitude = json["latitude"].numberValue
        var fences = NSMutableSet()
        for fence in json["fences"].arrayValue {
            var fence = Geofence.createWithJSON(fence, context: context)
            fences.addObject(fence)
        }
        self.addFences(fences)
    }
    /**
    * Class Functions
    */
    class func createWithJSON(json: JSON) -> Bridge{
        return Bridge.createWithJSON(json, context: NSManagedObjectContext.MR_context())
    }
    class func createWithJSON(json: JSON, context: NSManagedObjectContext) -> Bridge {
        var bridge: Bridge
        bridge = Bridge.MR_createEntityInContext(context)
        bridge.updateExceptUnchangeables(json, context: context)
        bridge.tracking = false
        context.MR_saveToPersistentStoreAndWait()
        return bridge
    }
    /**
    * findWithID
    *
    * finds the first instance with the given id
    */
    class func findWithID(id: NSNumber) -> Bridge? {
        var bridge = Bridge.MR_findFirstByAttribute("id", withValue: id)
        return bridge
    }
    /**
    * findAndUpdateChangeablesOrCreateWithJSON
    *
    * Tries to find a bridge with the given id and if found the bridge
    * will be updated, else the bridge will be created and stored in the
    * persistent store.
    */
    class func findAndUpdateChangeablesOrCreateWithJSON(json: JSON, context: NSManagedObjectContext) -> Bridge {
        var bridge: Bridge? = Bridge.findWithID(json["id"].numberValue)
        if let isBridge = bridge {
            //the bridge is not nil so update the some attributes
            bridge?.updateExceptUnchangeables(json, context: context)
            return bridge!
        }
        return Bridge.createWithJSON(json, context: context)
    }
    /**
    * REST Methods
    */
    static let bridgesURL = NSURL(string: "http://dev.waittimes.io:8080/api/v1/bridges")
    static let session: NSURLSession = NSURLSession.sharedSession()
    /**
    * GetAllBridges
    *
    * Gets all the bridges from server in json format and calls the given
    * closure with an array of the pertaining bridges.
    */
    class func GetAllBridges(#bridgeReceiver: ([Bridge] -> Void)) -> NSManagedObjectContext {
        var context = NSManagedObjectContext.MR_context()
        var bridges = [Bridge]()
        Bridge.session.dataTaskWithURL(
            Bridge.bridgesURL!,
            completionHandler: {
                (data, response, errors) -> Void in
                    let json = JSON(data: data)
                    for bridgeJSON in json.arrayValue {
                        bridges.append(Bridge.createWithJSON(bridgeJSON, context: context))
                    }
                bridgeReceiver(bridges)
            }
        ).resume()
        return context
    }
}
