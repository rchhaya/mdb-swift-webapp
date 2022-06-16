import App
import MongoDBVapor
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let app = Application(env)
try configure(app)

// Configure the app for using a MongoDB server at the provided connection string.
try app.mongoDB.configure("mongodb+srv://rchhaya:Sparker007!MongoDB@demo-cluster.g44zg.mongodb.net/?retryWrites=true&w=majority")

defer {
    // Cleanup the application's MongoDB data.
    app.mongoDB.cleanup()
    // Clean up the driver's global state. The driver will no longer be usable from this program after this method is
    // called.
    cleanupMongoSwift()
    app.shutdown()
}

try app.run()
