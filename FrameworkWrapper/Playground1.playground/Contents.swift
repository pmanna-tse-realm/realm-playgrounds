// Before launching the Playground, ensure to Build the placeholder FrameworkWrapper!

import UIKit
import CoreLocation
import FrameworkWrapper
import Realm
import RealmSwift


class Location: EmbeddedObject {
    @objc dynamic var latitude: CLLocationDegrees    = 0.0
    @objc dynamic var longitude: CLLocationDegrees    = 0.0
    
    var clLocation: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init()
        
        self.latitude    = latitude
        self.longitude    = longitude
    }
    
    convenience init(clLocation: CLLocation) {
        self.init()
        
        latitude    = clLocation.coordinate.latitude
        longitude    = clLocation.coordinate.longitude
    }
}

class ViewPoint: EmbeddedObject {
    @objc dynamic var name: String    = ""
    @objc dynamic var location: Location?
    
    convenience init(name: String, location: CLLocation?) {
        self.init()
        
        self.name        = name
        if location != nil {
            self.location    = Location(clLocation: location!)
        }
    }
}

class Journey: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var _partition: ObjectId?
    @objc dynamic var name: String            = ""
    @objc dynamic var location: Location?
    
    let viewPoints    = List<ViewPoint>()
    
    override static func primaryKey() -> String? { "_id" }
    
    convenience init(partition: ObjectId, name: String) {
        self.init()
        
        _partition = partition
        self.name = name
    }
}

let app = App(id: "sceneries-iivuy")

app.syncManager.logLevel    = .trace

app.login(credentials: Credentials.anonymous) { result in
    DispatchQueue.main.async {
		let user: User
		
		switch result {
		case let .success(maybeUser):
			user = maybeUser
		case let .failure(error):
			print("Call to MongoDB failed: \(error.localizedDescription)")
			return
		}
		
        guard let userIdentity = try? ObjectId(string: user.id) else {
            print ("Must be logged in to access this view")
            
            return
        }
        
        var realm: Realm!
        
        // Open a realm with the partition key set to the user.
        do {
            realm = try Realm(configuration: user.configuration(partitionValue: userIdentity))
        } catch {
            print (error.localizedDescription)
            
            return
        }
        
        let journey = Journey(partition: userIdentity, name: "New Journey \(Int.random(in: 0..<1000))")
        
        journey.location    = Location(latitude: 52.35 + Double.random(in: 0.0..<3.0),
                                       longitude: -6.35 + Double.random(in: 0.0..<1.0))
        
        // All writes must happen in a write block.
        try! realm.write {
            realm.add(journey)
        }
        
        let viewPoint1 = ViewPoint(name: "ViewPoint 1",
                                   location: CLLocation(latitude: 52.35 + Double.random(in: 0.0..<3.0),
                                                        longitude: -6.35 + Double.random(in: 0.0..<1.0)))
        let viewPoint2 = ViewPoint(name: "ViewPoint 2",
                                  location: CLLocation(latitude: 52.35 + Double.random(in: 0.0..<3.0),
                                                       longitude: -6.35 + Double.random(in: 0.0..<1.0)))
        let viewPoint3 = ViewPoint(name: "ViewPoint 3",
                                  location: nil)

        print(viewPoint1.name)
        print(viewPoint1.location!.clLocation.coordinate)
        print(viewPoint2.name)
        print(viewPoint2.location!.clLocation.coordinate)
        print(viewPoint3.name)
		print(viewPoint3.location?.clLocation.coordinate ?? "None")

        try! realm.write {
            journey.viewPoints.append(viewPoint1)
            journey.viewPoints.append(viewPoint2)
            journey.viewPoints.append(viewPoint3)
        }
    }
}
