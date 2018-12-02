import Foundation

class GameData: Codable {

    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func getNextMove() -> Move {
        if let moveToKill = getMoveToKill() { return moveToKill }
        let pathFinder = AStarPathfinder()
        pathFinder.datasource = self
        let descriptor = PlayerMoveDescriptor(goalPosition: getGoalPosition(), pathFinder: pathFinder)
        return player.getMove(descriptor: descriptor)
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
        let killPositions = player.killPositions
        
        //Check if there is 
        
        return nil
    }
//
//    func getKillablePlayerPosition(positions: [Position]) -> Position? {
//        return positions.first(where: players.contains)
//    }
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
