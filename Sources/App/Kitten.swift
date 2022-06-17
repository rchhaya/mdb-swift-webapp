import Foundation
import MongoDBVapor
import Vapor

/// Possible cat food choices.

/// The structure of an update request.

/// Represents a kitten.
struct Kitten: Content {
    /// Unique identifier.
    // let _id: BSONObjectID?
    /// Favorite food.
    let lastUpdateTime: Date
    let name: String
    ///
    let bench: Int?
    let squat: Int?
    let ohp: Int?
    let benchTraining: Int?
    let squatTraining: Int?
    let ohpTraining: Int?

}