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
}

struct Move: Codable {
    private let move: String

    init(_ move: String) {
        self.move = move
    }
}

extension Move: Content {}