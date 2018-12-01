import Foundation

class GameData: Codable {
    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
    
    func isValidPosition(position: Position) -> Bool {
        return !(board.walls.contains(position) &&
            players.contains(position) &&
            invaders.contains { $0.position == position })
    }
}

extension GameData: PathFinderDataSource {
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = [position.top, position.left, position.bottom, position.right]
        return adjacentTiles.filter(isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
}

