import Vapor

struct GameController: RouteCollection {
    func boot(router: Router) throws {
        router.post("name", use: getCredentials)
        router.post("move", use: getNextMove)
    }
    
    func getCredentials(_ req: Request) throws -> Credentials {
        return Credentials()
    }
    
    func getNextMove(_ req: Request) throws -> Future<Move> {
        return try req.content.decode(GameData.self).map { gameData -> Move in
            let decisionController = DecisionController(gameData)
            return decisionController.getNextMove()
        }
    }
}
