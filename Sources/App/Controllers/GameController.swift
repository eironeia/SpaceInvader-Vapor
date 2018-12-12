import Vapor

//MARK: - Equatable
extension MoveData: Equatable {}
func ==(lhs: MoveData, rhs: MoveData) -> Bool {
    return lhs.move == rhs.move && lhs.position == rhs.position
}

class GameController: RouteCollection {
    func boot(router: Router) throws {
        router.post("name", use: getCredentials)
        router.post("move", use: getMove)
    }
    
    func getCredentials(_ req: Request) throws -> Credentials {
        print("GETTING CREDENTIALS")
        MovesStack.shared.startTimer()
        return Credentials()
    }
    
    func getMove(_ req: Request) throws -> Future<Move> {
        return try req.content.decode(GameData.self).map { gameData -> Move in
            print("**************************")
            let nextMove = gameData.getNextMove()
            print(nextMove ?? "NO NEXT MOVE")
            let move = nextMove ?? Move.getMove(from: .down)
            MovesStack.shared.addMovement(movement: MoveData(move: move, position: gameData.player.position))
            return move
        }
    }
}
