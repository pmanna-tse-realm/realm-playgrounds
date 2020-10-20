import Foundation
import FrameworkWrapper
import Realm
import RealmSwift

class TestData: Object {
	@objc dynamic var _id: ObjectId = ObjectId.generate()
	@objc dynamic var _partition = "Global"
	let mediumInt:Int32	= 0
	let longInt			= RealmOptional<Int>()
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

let app = App(id: "testbed-eobcc")

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
		
		var realm: Realm!
		
		// Open a realm with the partition key set to a fixed value.
		do {
			realm = try Realm(configuration: user.configuration(partitionValue: "Global"))
			
			let allObjects   = realm.objects(TestData.self)
			
			print("All objects: \(allObjects.count)")
		} catch {
			print (error.localizedDescription)
			
			return
		}
	}
}
