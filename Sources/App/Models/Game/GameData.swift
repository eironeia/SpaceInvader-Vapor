import Foundation

class GameData: Codable {

    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func getNextMove() -> Move? {
        //Kill if I have fire
        if let moveToKill = getMoveToKill() { return moveToKill }
        //Start A* Algorithm
        let pathFinder = AStarPathfinder()
        pathFinder.datasource = self
        //Get saved walls for this game
        let walls = getWalls()
        let mapsDataCandidatePositionDescriptor = MapsDataCandidatePositionsDescriptor(gameID: game.id.uuidString,
                                                                             playerPosition: player.position,
                                                                             board: board,
                                                                             isValidPosition: isValidPosition,
                                                                             isInBoard: isPositionOnBoard)
        let descriptor = PlayerMoveDescriptor(players: players,
                                              invaders: invaders,
                                              walls: walls,
                                              pathFinder: pathFinder,
                                              board: board,
                                              area: player.area,
                                              isValidPosition: isValidPosition,
                                              mapsDataCandidatePositionDescriptor: mapsDataCandidatePositionDescriptor)
        return player.getMove(descriptor: descriptor)
    }
}

private extension GameData {
    
    func isValidPosition(position: Position) -> Bool {
        return !getWalls().contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: position) }
    }
    
    func getMoveToKill() -> Move? {
        let descriptor = PlayerKillMoveDescriptor(players: players,
                                                  invaders: invaders,
                                                  walls: board.walls)
        return player.getKillMove(descriptor: descriptor)
    }
    
    func getWalls() -> [Position] {
        let wallsDescriptor = WallsDataDescriptor(gameID: game.id.uuidString, walls: board.walls)
        return MapsData.shared.getWalls(descriptor: wallsDescriptor)
    }
    
    func isPositionOnBoard(position: Position) -> Bool {
        return position.x >= 0 && position.y >= 0 && position.x < board.size.width && position.y < board.size.height
    }
}

extension GameData: PathFinderDataSource {
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = position.adjacentPositions()
        return adjacentTiles.filter(isPositionOnBoard).filter(isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
}
