import Vapor

enum MoveTypes: String, CaseIterable {
    case up
    case down
    case left
    case right
    case fireUp = "fire-up"
    case fireDown = "fire-down"
    case fireRight = "fire-right"
    case fireLeft = "fire-left"
    
    static var movements: [MoveTypes] {
        return [.up, down, .left, .right]
    }
}

struct Move: Codable {
    let move: String

    init(_ move: String) {
        self.move = move
    }
    
    static func getMove(from moveType: MoveTypes) -> Move {
        return Move(moveType.rawValue)
    }
}

//MARK: - Equatable
extension Move: Equatable {}
func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.move == rhs.move
}


extension Move: Content {}
