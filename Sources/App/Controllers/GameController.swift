import Vapor

struct MoveData {
    let move: Move
    let position: Position
}

class MovesStack {
    static let shared = MovesStack()
    private var movements: [MoveData] = [] {
        didSet {
            print("Movements count:", movements.count)
        }
    }
    private var timer: Timer?
    
    private init() {}
    
    func  startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(trigger), userInfo: nil, repeats: false)
    }
    
    @objc
    private func trigger() {
        self.movements = []
    }
    
    func addMovement(movement: MoveData) {
        movements.append(movement)
        timer?.invalidate()
        startTimer()
    }
    
    var shouldCheckForDodge: Bool {
        if movements.count > 2 {
            let last1Index = movements.count - 1
            let last2Index = movements.count - 2
            let last3Index = movements.count - 3
            return (movements[last1Index], movements[last2Index]) == (movements[last2Index], movements[last3Index])
        }
        return false
    }
}

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
