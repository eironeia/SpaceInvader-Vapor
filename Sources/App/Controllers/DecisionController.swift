import Foundation

class DecisionController {
    private let gameData: GameData
    private let pathFinder = AStarPathfinder()
    private var shortestPath: [Position]?
    
    init(_ gameData: GameData) {
        self.gameData = gameData
        pathFinder.datasource = self
    }
    
    func getNextMove() -> Move {
        //Find the closest
        let mockPosition = Position(x: 2, y: 2)
        shortestPath = pathFinder.shortestPath(current: gameData.player.position, goal: mockPosition)
        if let shortestPath = shortestPath,
            let nextPosition = shortestPath.first {
            let moveType = gameData.player.position.getMoveTo(nextPosition: nextPosition)
            return Move(moveType.rawValue)
        } else {
            return Move(MoveTypes.up.rawValue)
        }
    }
}

extension DecisionController: PathFinderDataSource {
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = [position.top, position.left, position.bottom, position.right]
        return adjacentTiles.filter(gameData.isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
}
