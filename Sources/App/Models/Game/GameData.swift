import Foundation

class GameData: Codable {

    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func getNextMove() -> Move? {
//        if MovesStack.shared.shouldCheckForDodge, let dodgeMovement = getDodgeMovement() { return dodgeMovement }
        if let moveToKill = getMoveToKill() { return moveToKill }
        let pathFinder = AStarPathfinder()
        pathFinder.datasource = self
        let descriptor = PlayerMoveDescriptor(players: players, invaders: invaders, walls: board.walls, pathFinder: pathFinder, board: board, isValidPosition: isValidPosition)
        return player.getMove(descriptor: descriptor)
    }
}

private extension GameData {
    
    func isValidPosition(position: Position) -> Bool {
        return !board.walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: position) }
    }
    
    func getMoveToKill() -> Move? {
        let descriptor = getPlayerKillMoveDescriptor()
        return player.getKillMove(descriptor: descriptor)
    }
    
    func getPlayerKillMoveDescriptor() -> PlayerKillMoveDescriptor {
        return PlayerKillMoveDescriptor(players: players,
                                        invaders: invaders,
                                        walls: board.walls)
    }
    
//    func getDodgeMovement() -> Move? {
//        let descriptor = getPlayerKillMoveDescriptor()
//        
//    }
}

extension GameData: PathFinderDataSource {
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = position.adjacentPositions()
        return adjacentTiles.filter(player.isPositionOnArea).filter(isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
}
