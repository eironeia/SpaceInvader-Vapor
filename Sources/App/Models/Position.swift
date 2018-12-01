import Foundation

struct Position: Codable {
    let x: Int
    let y: Int
    
    var top: Position { return Position(x: x, y: y - 1) }
    var left: Position { return Position(x: x - 1, y: y) }
    var right: Position { return Position(x: x + 1, y: y) }
    var bottom: Position { return Position(x: x, y: y + 1) }
    
    func getMoveTo(nextPosition: Position) -> MoveTypes {
        if (nextPosition.y - y) == -1 { return MoveTypes.up }
        if (nextPosition.y - y) == 1 { return MoveTypes.down }
        if (nextPosition.x - x) == -1 { return MoveTypes.left }
        if (nextPosition.x - x) == 1 { return MoveTypes.right }
        return MoveTypes.up
    }
}

extension Position: Equatable {}
func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.y == rhs.y && lhs.x == rhs.x
}

// Allow expressions such as let diff = coord1 - coord2
func -(lhs: Position, rhs: Position) -> Position {
    return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

