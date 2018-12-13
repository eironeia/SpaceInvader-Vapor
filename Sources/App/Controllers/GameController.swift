import Vapor

class GameController: RouteCollection {
    func boot(router: Router) throws {
        router.post("name", use: getCredentials)
        router.post("move", use: getMove)
        router.get("reset123", use: resetStuff)
    }
    
    func getCredentials(_ req: Request) throws -> Credentials {
        print("GETTING CREDENTIALS")
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
    
    func resetStuff(_ req: Request) throws -> String {
        MapsData.shared.resetStuff()
        return "Cleaned!"
    }
}
