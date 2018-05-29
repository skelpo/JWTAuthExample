# JWTAuthExample

In this project you can see an example implementation of [JWTMiddleware](https://github.com/skelpo/JWTMiddleware). The approach can be used in micro-services or webpages that need to verify incoming JWTs and use the data somehow.

## Install

You will need to add the following two packages to your `Package.swift`:

```swift
.package(url: "https://github.com/vapor/jwt.git", from: "3.0.0-rc"),
.package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.6.1"),
```

And add `JWTMiddleware` as well as `JWT` to all the target dependency arrays you want to access the package in.

Complete the installation by running `vapor update` or `swift package update`.

## Configuration

You will need to register two services in your `configure.swift`:

```swift
/// We need this for the JWTProvider, coming from Vapor
try services.register(StorageProvider())
/// Adding the JWTProvider for us to validate JWTs
try services.register(JWTProvider { n in
    let headers = JWTHeader(alg: "RS256", crit: ["exp", "aud"]) // change as needed
    return try RSAService(n: n, e: "AQAB", header: headers
)})
```

## Models

To work with the payload from the JWT you will need a payload model:
```swift
import Foundation
import JWT
import JWTMiddleware

/// A representation of the payload used in the access tokens
/// for this service's authentication.
struct Payload: IdentifiableJWTPayload {
    let exp: TimeInterval
    let iat: TimeInterval
    
    // These two are to be customized according to what is in the JWT
    let email: String
    let id: Int
    
    
    func verify() throws {
        let expiration = Date(timeIntervalSince1970: self.exp)
        try ExpirationClaim(value: expiration).verify()
    }
}
```
## Routes

Routes can look any way you like but here are two examples:

```swift
// This simple validates the request, no payload data is used
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
```
