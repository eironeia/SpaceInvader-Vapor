import Foundation

protocol InvaderProtocol {
    var position: Position { get }
    func isNeutralInvaderOn(position: Position) -> Bool
    func isNoNeutralInvaderOn(position: Position) -> Bool
}

struct Invader: Codable, InvaderProtocol {
    let x: Int
    let y: Int
    let neutral: Bool
    
    var position: Position {
        return Position(x: x, y: y)
    }
    
    func isNeutralInvaderOn(position: Position) -> Bool {
        return (self.position == position) && neutral
    }
    
    func isNoNeutralInvaderOn(position: Position) -> Bool {
        return (self.position == position) && !neutral
    }
    
    func getKillPositions(area: Area) -> [Position] {
        return position.getKillPositions(area: area)
    }
    
    
}
