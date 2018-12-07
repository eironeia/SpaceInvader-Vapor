import Foundation

struct DirectionHelper {
    
    let position: Position
    
    init(position: Position) {
        self.position = position
    }
    
    func getMove(to nextPosition: Position) -> Move {
        if nextPosition.y < position.y { return Move.getMove(from: MoveTypes.up) }
        if nextPosition.y > position.y { return Move.getMove(from: MoveTypes.down) }
        if nextPosition.x < position.x { return Move.getMove(from: MoveTypes.left) }
        if nextPosition.x > position.x { return Move.getMove(from: MoveTypes.right) }
        print("SOMETHING BAD ❌")
        return Move.getMove(from: MoveTypes.up)
    }
    
    func getNewSameDirectionAsPrevious(previous: Position) -> Position {
        if previous == position.left { return position.right }
        if previous == position.right {  return position.left }
        if previous == position.top { return position.down }
        if previous == position.down { return position.top }
        print("THIS SHOULD NOT BE TRIGGERED")
        return position.right
    }
    
    func getSmartDirection(previous: Position, possiblePositions: [Position]) -> Position? {
        var candidate = getNewSameDirectionAsPrevious(previous: previous)
        if possiblePositions.contains(candidate) { return candidate }
        print("GETTING CANDIDATE 🔥🔥🔥🔥🔥🔥")
        if getCandidate(positions: possiblePositions, candidate: &candidate) { return candidate }
        if getCandidate(positions: possiblePositions, candidate: &candidate) { return candidate }
        if getCandidate(positions: possiblePositions, candidate: &candidate) { return candidate }
        if getCandidate(positions: possiblePositions, candidate: &candidate) { return candidate }
        print("ERROR ❌❌❌❌❌❌")
        return nil
    }
    
    func getNextClockPosition(candidate: Position) -> Position {
        if candidate == position.top { return position.right }
        if candidate == position.right { return position.down }
        if candidate == position.down { return position.left }
        if candidate == position.left { return position.top }
        print("THIS SHOULDN'T BE CALLED")
        return position.top
    }
}

private extension DirectionHelper {
    func getCandidate(positions: [Position], candidate: inout Position) -> Bool {
        candidate = getNextClockPosition(candidate: candidate)
        return positions.contains(candidate)
    }
}
