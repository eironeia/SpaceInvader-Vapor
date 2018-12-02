import Foundation

class GameData: Codable {

    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func getNextMove() -> Move {
        if let moveToKill = getMoveToKill() { return moveToKill }
//        let pathFinder = AStarPathfinder()
//        pathFinder.datasource = self
//        let descriptor = PlayerMoveDescriptor(goalPosition: getGoalPosition(), pathFinder: pathFinder)
//        return player.getMove(descriptor: descriptor)
        return Move.getMove(from: .down)
    }
}

private extension GameData {
    
    func getGoalPosition() -> Position {
        //Check for KILLABLE on zone if fire is true
        //
        return Position(x: 1, y: 1)
    }
    
    func isValidPosition(position: Position) -> Bool {
        return !board.walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.position == position && !$0.neutral }
    }
    
    func getMoveToKill() -> Move? {
        let descriptor = PlayerKillMoveDescriptor(players: players, invaders: invaders)
        return player.getKillMove(descriptor: descriptor)
    }
}

extension GameData: PathFinderDataSource {
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = position.adjacentPositions()
        return adjacentTiles.filter(isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
}
