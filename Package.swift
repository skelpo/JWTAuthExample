// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "JWTAuthExample",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.1.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        
        // JWT Middleware to authenticate
        .package(url: "https://github.com/skelpo/JWTMiddleware.git", from: "0.8.1"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentSQLite", "Vapor", "JWTMiddleware", "JWT"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

