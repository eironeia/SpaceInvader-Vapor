import Foundation

class GameData: Codable {

    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func getNextMove() -> Move? {
        if let moveToKill = getMoveToKill() { return moveToKill }
        let pathFinder = AStarPathfinder()
        pathFinder.datasource = self
        guard let goalPosition = getGoalPosition() else { return nil }
        let descriptor = PlayerMoveDescriptor(goalPosition: goalPosition, pathFinder: pathFinder)
        return player.getMove(descriptor: descriptor)
    }
}

private extension GameData {
    
    func getGoalPosition() -> Position? {
        return player.getGoalPosition(descriptor: PlayerGoalPositionDescriptor(players: players, invaders: invaders, isValidPosition: isValidPosition))
    }
    
    func isValidPosition(position: Position) -> Bool {
        return !board.walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: position) }
    }
    
    func getMoveToKill() -> Move? {
        let descriptor = PlayerKillMoveDescriptor(players: players, invaders: invaders, walls: board.walls)
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
