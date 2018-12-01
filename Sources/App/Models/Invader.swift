import Foundation

struct Invader: Codable {
    let y: Int
    let x: Int
    let neutral: Bool
    
    var position: Position {
        return Position(x: x, y: y)
    }
}
