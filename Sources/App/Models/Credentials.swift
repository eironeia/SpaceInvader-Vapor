import Vapor

struct Credentials: Codable  {
    let name: String = "Eironeia"
    let email: String = "alejandro.cuello@privalia.com"
}

extension Credentials: Content {}
