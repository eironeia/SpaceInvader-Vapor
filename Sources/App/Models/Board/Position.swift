import Foundation

struct WeigtedPositon {
    let position: Position
    let weight: Int
}

struct Position: Codable {
    let x: Int
    let y: Int
    
    //Vertical
    private var top: Position { return Position(x: x, y: y - 1) }
    private var down: Position { return Position(x: x, y: y + 1) }
    //Horizontal
    private var left: Position { return Position(x: x - 1, y: y) }
    private var right: Position { return Position(x: x + 1, y: y) }
    //Diagonals
    private var topLeft: Position { return Position(x: x - 1, y: y - 1) }
    private var topRight: Position { return Position(x: x + 1, y: y - 1) }
    private var bottomLeft: Position { return Position(x: x - 1, y: y + 1) }
    private var bottomRight: Position { return Position(x: x + 1, y: y + 1) }
    
}

//MARK: -
extension Position {
    
    func adjacentPositions() -> [Position] {
        return [top, left, down, right]
    }
    
    func getMove(to nextPosition: Position) -> Move {
        if nextPosition.y < y { return Move.getMove(from: MoveTypes.up) }
        if nextPosition.y > y { return Move.getMove(from: MoveTypes.down) }
        if nextPosition.x < x { return Move.getMove(from: MoveTypes.left) }
        if nextPosition.x > x { return Move.getMove(from: MoveTypes.right) }
        return Move.getMove(from: MoveTypes.up)
    }
    
    func getKillPositions(area: Area) -> [Position] {
        var positions = [Position]()
        let xrange = (area.x1...area.x2)
        let yrange = (area.y1...area.y2)
        xrange.forEach { if x != $0 { positions.append(Position(x: $0, y: y)) } }
        yrange.forEach { if y != $0 { positions.append(Position(x: x, y: $0)) } }
        return positions
    }
    
//    func getWeightedPositions(area: Area) ->  [WeigtedPositon] {
//        return getAllPossiblePositions(area: area)
//            .map {WeigtedPositon(position: $0, weight: $0.distanceTo(position: self))}
//            .sorted { $0.weight < $1.weight }
//    }
}

private extension Position {
    func getAllPossiblePositions(area: Area) -> [Position] {
        var positions = [Position]()
        let xrange = (area.x1...area.x2)
        let yrange = (area.y1...area.y2)
        xrange.forEach { xCoord in
            yrange.forEach { yCoord in
                positions.append(Position(x: xCoord, y: yCoord))
            }
        }
        return positions
    }
    
    func distanceTo(position: Position) -> Int {
        return max(abs(x-position.x), abs(y - position.y))
    }
}

extension Position: Equatable {}
func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.y == rhs.y && lhs.x == rhs.x
}

func -(lhs: Position, rhs: Position) -> Position {
    return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

extension Position: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}
