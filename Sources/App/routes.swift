import Vapor
import JWTMiddleware

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    // This simple validates the reponse, no payload data is used
    let protected = router.grouped(JWTVerificationMiddleware()).grouped("protected")
    protected.get("test") { req in
        return "You need to have a valid JWT for this!"
    }
    
    // Here we are using the data
    let user = router.grouped(JWTStorageMiddleware<Payload>()).grouped("user")
    user.get("me") { req -> String in
        let payload:Payload = try req.get("skelpo-payload")!
        // You can now use the payload and do with it whatever you like.
        // For example you can use the user id to load related data or save data.
        return "This is the ID from the JWT: \(payload.id)"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
