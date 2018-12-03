import Foundation

protocol InvaderProtocol {
    var position: Position { get }
    func isNeutralInvaderOn(position: Position) -> Bool
    func isNoNeutralInvaderOn(position: Position) -> Bool
}

struct Invader: Codable, InvaderProtocol {
    let y: Int
    let x: Int
    let neutral: Bool
    
    var position: Position {
        return Position(x: x, y: y)
    }
    
    func isNeutralInvaderOn(position: Position) -> Bool {
        return x == position.x && y == position.y && neutral
    }
    
    func isNoNeutralInvaderOn(position: Position) -> Bool {
        return x == position.x && y == position.y && !neutral
    }
}
