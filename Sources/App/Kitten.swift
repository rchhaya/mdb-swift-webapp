import Foundation
import MongoDBVapor
import Vapor

/// Possible cat food choices.
enum CatFood: String, Codable {
    case salmon,
         tuna,
         chicken,
         turkey,
         beef
}

/// The structure of an update request.
struct KittenUpdate: Codable {
    /// The new favorite food.
    let favoriteFood: CatFood

    /// The new last update time.
    let lastUpdateTime: Date
}

/// Represents a kitten.
struct Kitten: Content {
    /// Unique identifier.
    let _id: BSONObjectID?
    /// Name.
    let name: String
    /// Last updated time.
    let lastUpdateTime: Date
    ///
    let bench: Int?
    let squat: Int?
    let ohp: Int?
    let benchTraining: Int?
}
