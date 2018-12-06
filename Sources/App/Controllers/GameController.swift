import Vapor

class GameController: RouteCollection {
    func boot(router: Router) throws {
        router.post("name", use: getCredentials)
        router.post("move", use: getMove)
    }
    
    func getCredentials(_ req: Request) throws -> Credentials {
        return Credentials()
    }
    
    func getMove(_ req: Request) throws -> Future<Move> {
        return try req.content.decode(GameData.self).map { gameData -> Move in
            print("**************************")
            let nextMove = gameData.getNextMove()
            print(nextMove ?? "NO NEXT MOVE")
            return nextMove ?? Move.getMove(from: .down)
        }
    }
}
