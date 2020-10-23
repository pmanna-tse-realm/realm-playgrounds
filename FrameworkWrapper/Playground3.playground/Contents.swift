import Foundation
import FrameworkWrapper
import Realm
import RealmSwift

@objcMembers class TestData: Object {
	dynamic var _id: ObjectId = ObjectId.generate()
	dynamic var _partition = "Global"
	let mediumInt	= RealmOptional<Int32>()
	let longInt		= RealmOptional<Int>()
	
	override static func primaryKey() -> String? {
		return "_id"
	}
}

let app = App(id: "testbed-eobcc")

app.syncManager.logLevel    = .trace

func openRealm(with user: User) -> Realm? {
	var realm: Realm!
	let config	= user.configuration(partitionValue: "Global")
	
	// Open a realm with the partition key set to a fixed value.
	do {
		realm = try Realm(configuration: config)
		
		let allObjects   = realm.objects(TestData.self)
		
		print("All objects: \(allObjects.count)")
		
		return realm
	} catch {
		print ("Query failed: \(error.localizedDescription)")
		
		return nil
	}

}

func doSomething(in realm: Realm) {
	do {
		try realm.write {
			let sample	= realm.create(TestData.self,
										 value: [ObjectId.generate(), "Global", Int32.max, Int.min],
										 update: .modified)
			
			print("Writing \(sample)")
		}
	} catch {
		print ("Write failed: \(error.localizedDescription)")
	}
}

app.login(credentials: Credentials.anonymous) { result in
	DispatchQueue.main.async {
		let user: User
		
		switch result {
		case let .success(maybeUser):
			user = maybeUser
		case let .failure(error):
			print("Login to MongoDB failed: \(error.localizedDescription)")
			return
		}
		
		guard let realm = openRealm(with: user) else { return }
		
		print("Realm opened: \(realm.configuration.fileURL!)")
		
		doSomething(in: realm)
	}
}
