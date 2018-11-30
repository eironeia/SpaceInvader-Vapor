import Vapor

struct GameController: RouteCollection {
    func boot(router: Router) throws {
        router.post("name", use: getCredentials)
        router.post("move", use: getNextMove)
    }
    
    func getCredentials(_ req: Request) throws -> Credentials {
        return Credentials()
    }
    
    func getNextMove(_ req: Request) throws -> Move {
//        Uncomment when goes to be uploaded
//        return try req.content.decode(GameData.self).map { gameData -> Move in
//            return Move(MoveTypes.down.rawValue)
//        }
        
        return Move(MoveTypes.down.rawValue)
    }
}
