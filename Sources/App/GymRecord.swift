import Foundation
import MongoDBVapor
import Vapor

/// Represents a record.
struct GymRecord: Content {
    /// Unique identifier.
    let _id: BSONObjectID?
    /// Name.
    var name: String
    /// Last updated time.
    let lastUpdateTime: Date
    ///
    let lift1: Int?
    let lift2: Int?
    let lift3: Int?
    
    internal mutating func setName(name: String) {
        self.name = name
    }
}
