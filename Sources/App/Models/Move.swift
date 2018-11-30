import Vapor

enum MoveTypes: String {
    case up
    case down
    case left
    case right
    case fireUp = "fire-up"
    case fireDown = "fire-down"
    case fireRight = "fire-right"
    case fireLeft = "fire-left"
    
    static var allCases: [MoveTypes] {
        return [.up, .down, .left, .right] //, .fireUp, .fireDown, .fireRight, .fireLeft
    }
}

struct Move: Codable {
    private let move: String

    init(_ move: String) {
        self.move = move
    }
}

extension Move: Content {}
