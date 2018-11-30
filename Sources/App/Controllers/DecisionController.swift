import Foundation

struct DecisionController {
    private let gameData: GameData
    
    init(_ gameData: GameData) {
        self.gameData = gameData
    }
    
    func getNextMove() -> Move {
        return Move(MoveTypes.down.rawValue)
    }
}
