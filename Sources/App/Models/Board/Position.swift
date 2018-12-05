import Foundation

protocol KillPositionProtocol {
    func getKillPositions(area: Area) -> [Position]
}

protocol DistancePositionProtocol {
    func distanceTo(position: Position) -> Int
}

protocol PositionInvalidProtocol {
    func isWallBetween(xPosition: Int, walls: [Position]) -> Bool
    func isWallBetween(yPosition: Int, walls: [Position]) -> Bool
}

protocol MovementPositionProtocol {
    func getMove(to nextPosition: Position) -> Move
}

struct Position: Codable {
    let x: Int
    let y: Int
    
    //Vertical
    var top: Position { return Position(x: x, y: y - 1) }
    var down: Position { return Position(x: x, y: y + 1) }
    //Horizontal
    var left: Position { return Position(x: x - 1, y: y) }
    var right: Position { return Position(x: x + 1, y: y) }
    //Diagonals
    private var topLeft: Position { return Position(x: x - 1, y: y - 1) }
    private var topRight: Position { return Position(x: x + 1, y: y - 1) }
    private var bottomLeft: Position { return Position(x: x - 1, y: y + 1) }
    private var bottomRight: Position { return Position(x: x + 1, y: y + 1) }
 
    func adjacentPositions() -> [Position] {
        return [top, left, down, right]
    }
}

//MARK: - Movement
extension Position: MovementPositionProtocol {
    func getMove(to nextPosition: Position) -> Move {
        if nextPosition.y < y { return Move.getMove(from: MoveTypes.up) }
        if nextPosition.y > y { return Move.getMove(from: MoveTypes.down) }
        if nextPosition.x < x { return Move.getMove(from: MoveTypes.left) }
        if nextPosition.x > x { return Move.getMove(from: MoveTypes.right) }
        print("HERE IS THE UP MOVEMENT")
        return Move.getMove(from: MoveTypes.up)
    }
    
    func getNextClockPosition(candidate: Position) -> Position {
        if candidate == top { return right }
        if candidate == right { return down }
        if candidate == down { return left }
        if candidate == left { return top }
        print("THIS SHOULDN'T BE CALLED")
        return top
    }
    
    func getNewSameDirectionAsPrevious(previous: Position) -> Position {
        print("Previous:", previous, "Current:", self)
        if previous == left { return right }
        if previous == right {  return left }
        if previous == top { return down }
        if previous == down { return top }
        print("THIS SHOULD NOT BE TRIGGERED")
        return down
    }
}

//MARK: - PositionInvalidProtocol
extension Position: PositionInvalidProtocol {
    func isWallBetween(xPosition: Int, walls: [Position]) -> Bool {
        if xPosition < x {
            let range = (xPosition...x)
            for x in range {
                if walls.contains(where: { $0.x == x && $0.y == y}) { return true }
            }
        } else {
            let range = (x...xPosition)
            for x in range {
                if walls.contains(where: { $0.x == x && $0.y == y}) { return true }
            }
        }
        return false
    }
    
    func isWallBetween(yPosition: Int, walls: [Position]) -> Bool {
        if yPosition < y {
            let range = (yPosition...y)
            for y in range {
                if walls.contains(where: { $0.y == y && $0.x == x}) { return true }
            }
        } else {
            let range = (y...yPosition)
            for y in range {
                if walls.contains(where: { $0.y == y && $0.x == x}) { return true }
            }
        }
        return false
    }
}

//MARK: - DistancePositionProtocol
extension Position: DistancePositionProtocol {
    func distanceTo(position: Position) -> Int {
        let differencePosition = self - position
        return max(abs(differencePosition.x), abs(differencePosition.y))
    }
    
    func stepsTo(position: Position) -> Int {
        let differencePosition = self - position
        return abs(differencePosition.x) + abs(differencePosition.y)
    }
}

//MARK: - KillPositionProtocol
extension Position: KillPositionProtocol {
    func getKillPositions(area: Area) -> [Position] {
        var positions = [Position]()
        positions += area.getHorizontalPositions(without: self)
        positions += area.getVerticalPositions(without: self)
        return positions
    }
}

//MARK: - Equatable
extension Position: Equatable {}
func ==(lhs: Position, rhs: Position) -> Bool {
    return lhs.y == rhs.y && lhs.x == rhs.x
}

func -(lhs: Position, rhs: Position) -> Position {
    return Position(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

//MARK: - CustomStringConvertible
extension Position: CustomStringConvertible {
    var description: String {
        return "(\(x), \(y))"
    }
}
