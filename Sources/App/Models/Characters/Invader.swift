import Foundation

struct Invader: Codable {
    let y: Int
    let x: Int
    let neutral: Bool
    
    var position: Position {
        return Position(x: x, y: y)
    }
    
    func isNeutralInvaderOn(position: Position) -> Bool {
        return x == position.x && y == position.y && neutral
    }
    
    func isNoNeutralInvader(position: Position) -> Bool {
        return x == position.x && y == position.y && !neutral
    }
}
