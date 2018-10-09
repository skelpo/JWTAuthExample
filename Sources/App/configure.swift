import FluentSQLite
import Vapor
import JWTMiddleware

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// We need this for the JWTProvider
    try services.register(StorageProvider())
    
    /// Adding the JWTProvider for us to validate JWTs
    try services.register(JWTProvider { _ , pem  in
        guard let pem = pem else { throw Abort(.internalServerError, reason: "Could not find environment variable 'JWT_SECRET'", identifier: "missingEnvVar") }
        let headers = JWTHeader(alg: "RS256", crit: ["exp", "aud"], kid: "user_manager_kid")
        return try RSAService(pem: pem, header: headers, type: .private, algorithm: .sha512)
    })


    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let sqlite = try SQLiteDatabase(storage: .memory)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: sqlite, as: .sqlite)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)

}
