import MongoDBVapor
import Vapor

/// Adds a collection of web routes to the application.
func webRoutes(_ app: Application) throws {
    /// Handles a request to load the main index page containing a list of records.
    app.get { req async throws -> View in
        let records = try await req.findRecords()
        // Return the corresponding Leaf view, providing the list of records as context.
        return try await req.view.render("index.leaf", ["records": records])
    }

    /// Handles a request to load a page with info about a particular record.
    app.get("records", ":name") { req async throws -> View in
        let record = try await req.findRecord()
        // Return the corresponding Leaf view, providing the record as context.
        return try await req.view.render("record.leaf", record)
    }
    
    app.get("hello") { req -> String in
        return "hello world!"
    }
}

// Adds a collection of rest API routes to the application.
func restAPIRoutes(_ app: Application) throws {
    let rest = app.grouped("rest")

    /// Handles a request to load the list of records.
    rest.get { req async throws -> [GymRecord] in
        try await req.findRecords()
    }

    /// Handles a request to add a new record.
    rest.post { req async throws -> Response in
        print("here")
        return try await req.addRecord()
    }

    /// Handles a request to load info about a particular record.
    rest.get("records", ":name") { req async throws -> GymRecord in
        try await req.findRecord()
    }

    rest.delete("records", ":name") { req async throws -> Response in
        try await req.deleteRecord()
    }

//    rest.patch("records", ":name") { req async throws -> Response in
//        try await req.updateRecord()
//    }
}

extension Request {
    /// Convenience extension for obtaining a collection.
    var recordCollection: MongoCollection<GymRecord> {
        application.mongoDB.client.db("personal").collection("gymRecorder", withType: GymRecord.self)
    }

    /// Constructs a document using the name from this request which can be used a filter for MongoDB
    /// reads/updates/deletions.
    func getNameFilter() throws -> BSONDocument {
        // We only call this method from request handlers that have name parameters so the value
        // will always be available.
        guard let name = parameters.get("name") else {
            throw Abort(.internalServerError, reason: "Request unexpectedly missing name parameter")
        }
        return ["name": .string(name)]
    }

    func findRecords() async throws -> [GymRecord] {
        do {
            return try await recordCollection.find().toArray()
        } catch {
            throw Abort(.internalServerError, reason: "Failed to load records: \(error)")
        }
    }

    func findRecord() async throws -> GymRecord {
        let nameFilter = try getNameFilter()
        guard let record = try await recordCollection.findOne(nameFilter) else {
            throw Abort(.notFound, reason: "No record with matching name")
        }
        return record
    }
    
    func onlySpaces(string: String) -> Bool {
        for char in string {
            if char != " " {
                return false
            }
        }
        return true
    }

    func addRecord() async throws -> Response {
        var newRecord = try content.decode(GymRecord.self)
        if newRecord.name == "" || onlySpaces(string: newRecord.name) {
            let currCount = try await recordCollection.estimatedDocumentCount()
            let nameStr = String(currCount + 1)
            newRecord.setName(name: "Entry " + nameStr)
            print("potato man")
        }
        do {
            try await recordCollection.insertOne(newRecord)
            return Response(status: .created)
        } catch {
            // Give a more helpful error message in case of a duplicate key error.
            if let err = error as? MongoError.WriteError, err.writeFailure?.code == 11000 {
                throw Abort(.conflict, reason: "A record with the name \(newRecord.name) already exists!")
            }
            throw Abort(.internalServerError, reason: "Failed to save new record: \(error)")
        }
    }

    func deleteRecord() async throws -> Response {
        let nameFilter = try getNameFilter()
        do {
            // since we aren't using an unacknowledged write concern we can expect deleteOne to return a non-nil result.
            guard let result = try await recordCollection.deleteOne(nameFilter) else {
                throw Abort(.internalServerError, reason: "Unexpectedly nil response from database")
            }
            guard result.deletedCount == 1 else {
                throw Abort(.notFound, reason: "No record with matching name")
            }
            return Response(status: .ok)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to delete record: \(error)")
        }
    }

//    func updateRecord() async throws -> Response {
//        let nameFilter = try getNameFilter()
//        // Parse the update data from the request.
//        let update = try content.decode(RecordUpdate.self)
//        /// Create a document using MongoDB update syntax that specifies we want to set a field.
//        let updateDocument: BSONDocument = ["$set": .document(try BSONEncoder().encode(update))]
//
//        do {
//            // since we aren't using an unacknowledged write concern we can expect updateOne to return a non-nil result.
//            guard let result = try await recordCollection.updateOne(
//                filter: nameFilter,
//                update: updateDocument
//            ) else {
//                throw Abort(.internalServerError, reason: "Unexpectedly nil response from database")
//            }
//            guard result.matchedCount == 1 else {
//                throw Abort(.notFound, reason: "No record with matching name")
//            }
//            return Response(status: .ok)
//        } catch {
//            throw Abort(.internalServerError, reason: "Failed to update record: \(error)")
//        }
//    }
}
