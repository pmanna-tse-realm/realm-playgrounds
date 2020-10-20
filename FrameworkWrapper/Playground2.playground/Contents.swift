// Before launching the Playground, ensure to Build the placeholder FrameworkWrapper!

import Foundation
import FrameworkWrapper
import Realm
import RealmSwift

class MovieDetail_awards: EmbeddedObject {
    let nominations = RealmOptional<Int>()
    @objc dynamic var text: String? = nil
    let wins = RealmOptional<Int>()
}

class MovieDetail_imdb: EmbeddedObject {
    @objc dynamic var id: String? = nil
    let rating = RealmOptional<Double>()
    let votes = RealmOptional<Int>()
}

class MovieDetail_tomato: EmbeddedObject {
    @objc dynamic var consensus: String? = nil
    let fresh = RealmOptional<Int>()
    @objc dynamic var image: String? = nil
    let meter = RealmOptional<Int>()
    let rating = RealmOptional<Double>()
    let reviews = RealmOptional<Int>()
    let userMeter = RealmOptional<Int>()
    let userRating = RealmOptional<Double>()
    let userReviews = RealmOptional<Int>()
}

class MovieDetail: Object {
    @objc dynamic var _id: ObjectId? = nil
    @objc dynamic var _partition: String? = nil
    let actors = RealmSwift.List<String>()
    @objc dynamic var awards: MovieDetail_awards?
    let countries = RealmSwift.List<String>()
    @objc dynamic var director: String? = nil
    let genres = RealmSwift.List<String>()
    @objc dynamic var imdb: MovieDetail_imdb?
    let metacritic = RealmOptional<Int>()
    @objc dynamic var plot: String? = nil
    @objc dynamic var poster: String? = nil
    @objc dynamic var rated: String? = nil
    let runtime = RealmOptional<Int>()
    @objc dynamic var title: String? = nil
    @objc dynamic var tomato: MovieDetail_tomato?
    @objc dynamic var type: String? = nil
    let writers = RealmSwift.List<String>()
    let year = RealmOptional<Int>()
    override static func primaryKey() -> String? {
        return "_id"
    }
}


let app = App(id: "video-kvyxb")

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
            
            let allMovies   = realm.objects(MovieDetail.self)
            
            print("All movies: \(allMovies.count)")
            
            let filteredByActor = allMovies.filter { (detail) -> Bool in
                detail.actors.contains("Robert De Niro")
            }
            
            filteredByActor.forEach { (detail) in
                print("\(detail.title ?? "") --> \(detail.actors)")
            }
            
            let filteredByTitle = allMovies.filter { (detail) -> Bool in
                detail.title!.hasPrefix("The God")
            }
            
            filteredByTitle.forEach { (detail) in
                print("\(detail.title ?? "") --> \(detail.actors)")
            }
            
            // Do the same, but with Mongo Client
            let client = user.mongoClient("mongodb-atlas")
            
            // Select the database
            let database = client.database(named: "video")

            // Select the collection
            let collection = database.collection(withName: "movieDetails")

            // Run the query

            collection.find(filter: [:]) { result in
				// Note: this completion handler may be called on a background thread.
				//       If you intend to operate on the UI, dispatch back to the main
				//       thread with `DispatchQueue.main.sync {}`.
				switch result {
				case let .success(results):
					print("All movies (client): \(results.count)")
				case let .failure(error):
					print("Call to MongoDB failed: \(error.localizedDescription)")
				}
            }
        } catch {
            print (error.localizedDescription)
            
            return
        }
    }
}

