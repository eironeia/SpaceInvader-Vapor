import Foundation
import XCTest
@testable import App


class ShortestPathMock: PathFinderDataSource {
    let player: Player
    let walls: [Position]
    let invaders: [Invader]
    let players: [Position]
    
    init(player: Player, walls: [Position] = [], invaders: [Invader] = [], players: [Position] = []) {
        self.player = player
        self.walls = walls
        self.invaders = invaders
        self.players = players
    }
    
    func possibleNextPositions(from position: Position) -> [Position] {
        let adjacentTiles = position.adjacentPositions()
        return adjacentTiles.filter(player.isPositionOnArea).filter(isValidPosition)
    }
    
    func costOfNextPosition(current: Position, adjacent: Position) -> Int {
        return 1
    }
    
    func isValidPosition(position: Position) -> Bool {
        return !walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: player.position) }
    }
}

// x1 = 0 y1 = 0
// x2 = 0 y2 = 3
//
// (0,0) (1,0) (2,0)
// (0,1) (1,1) (2,1)
// (0,2) (1,2) (2,2)
// (0,3) (1,3) (2,3)

class ShortestPathTests: XCTestCase {
    
    var player: Player!
    var shortestPath: AStarPathfinder!
    
    override func setUp() {
        super.setUp()
        player = Player(id: UUID(),
                        name: "Alex",
                        position: Position(x: 1, y: 2),
                        previous: Position(x: 0, y: 2),
                        area: Area(y1: 0, x1: 0, y2: 3, x2: 2),
                        fire: true)
        shortestPath = AStarPathfinder()
    }
    
    override func tearDown() {
        player = nil
        shortestPath = nil
        super.tearDown()
    }
    
    // (0,0)   I   (2,0)
    //   W     W   (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testNoRoute() {
        let walls = [Position(x: 0, y: 1), Position(x: 1, y: 1), Position(x: 2, y: 1)]
        let candidateInvader = Invader(x: 1, y: 0, neutral: false)
        let invaders = [candidateInvader]
        let shortestPath = AStarPathfinder()
        let pathFinder = ShortestPathMock(player: player,
                                          walls: walls,
                                          invaders: invaders)
        shortestPath.datasource = pathFinder
        XCTAssertEqual(nil, shortestPath.shortestPath(current: player.position, goal: candidateInvader.position))
    }
    
    // (0,0)   I   (2,0)
    //   W     W   (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testRoute() {
        let walls = [Position(x: 0, y: 1), Position(x: 1, y: 1)]
        let candidateInvader = Invader(x: 1, y: 0, neutral: false)
        let invaders = [candidateInvader]
        let pathFinder = ShortestPathMock(player: player,
                                          walls: walls,
                                          invaders: invaders)
        shortestPath.datasource = pathFinder
        let solution = [Position(x: 2, y: 2), Position(x: 2, y: 1), Position(x: 2, y: 0), Position(x: 1, y: 0)]
        XCTAssertEqual(solution, shortestPath.shortestPath(current: player.position, goal: candidateInvader.position))
    }
}

