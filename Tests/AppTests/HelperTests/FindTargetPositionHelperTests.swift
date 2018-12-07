import Foundation
import XCTest
@testable import App

// x1 = 0 y1 = 0
// x2 = 0 y2 = 3
//
// (0,0) (1,0) (2,0)
// (0,1) (1,1) (2,1)
// (0,2) (1,2) (2,2)
// (0,3) (1,3) (2,3)

class FindTargetPositionHelperTests: XCTestCase {
    
    var player: Player!
    
    override func setUp() {
        super.setUp()
        player = Player(id: UUID(),
                        name: "Alex",
                        position: Position(x: 1, y: 2),
                        previous: Position(x: 0, y: 2),
                        area: Area(y1: 0, x1: 0, y2: 3, x2: 2),
                        fire: true)
    }
    
    override func tearDown() {
        player = nil
        super.tearDown()
    }
    
    //X = CURRENT PLAYER
    //   I     I    NI
    // (0,1) (1,1) (2,1)
    // (0,2)   X     I
    // (0,3) (1,3) (2,3)
    func testNeutralInvaderGoalPosition() {
        let invaders = [Invader(x: 0, y: 0, neutral: false),
                        Invader(x: 1, y: 0, neutral: false),
                        Invader(x: 2, y: 0, neutral: true),
                        Invader(x: 2, y: 2, neutral: false)]
        
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: self.player.position, invaders: invaders)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: [], invaders: invaders, walls: [], isValidPosition: isValidPosition)
        
        if  player.fire {
            let positions = findTargetPositionHelper.getNeutralInvaderPositions(descriptor: descriptor)
            XCTAssertEqual(invaders.filter { $0.neutral }.map { $0.position }, positions)
        }
    }
    
    //X = CURRENT PLAYER
    //   I   (1,0) (2,0)
    // (0,1) (1,1) (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testInvaderGoalPosition() {
        let players = [Position(x: 1, y: 2)]
        let invaders = [Invader(x: 0, y: 0, neutral: false)]
        
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: position, players: players, invaders: invaders)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: players, invaders: invaders, walls: [], isValidPosition: isValidPosition)
        
        if player.fire,
            let positions = findTargetPositionHelper.getInvaderPositions(descriptor: descriptor) {
            let position = positionWithLessSteps(positions: positions)!
            XCTAssertEqual(Position(x: 0, y: 2), position)
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   W     W   (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testInvaderWithWallsGoalPosition() {
        let players = [Position(x: 1, y: 2)]
        let invaders = [Invader(x: 1, y: 0, neutral: false)]
        let walls = [Position(x: 0, y: 1), Position(x: 1, y: 1)]
        
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: position, players: players, invaders: invaders, walls: walls)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: players, invaders: invaders, walls: walls, isValidPosition: isValidPosition)
        
        if player.fire,
            let positions = findTargetPositionHelper.getInvaderPositions(descriptor: descriptor) {
            XCTAssertEqual([Position(x: 0, y: 0), Position(x: 2, y: 0)], positions)
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   I   (1,1)   I
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testEmptyPositionWithInvaders() {
        let invaders = [Invader(x: 1, y: 0, neutral: false),
                        Invader(x: 0, y: 1, neutral: false),
                        Invader(x: 2, y: 1, neutral: false)]
        
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: position, invaders: invaders)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: [], invaders: invaders, walls: [], isValidPosition: isValidPosition)
        
        if let position = findTargetPositionHelper.getEmptyPosition(descriptor: descriptor) {
            XCTAssertEqual(position, Position.init(x: 1, y: 3))
        }
        
    }
    
    // (0,0) (1,0) (2,0)
    // (0,1) (1,1) (2,1)
    // (0,2) (1,2) (2,2)
    // (0,3) (1,3) (2,3)
    func testGetNewSameDirectionAsPrevious() {
        let current = Position(x: 1, y: 2)
        let directionHelper = DirectionHelper(position: current)
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 0, y: 2)), current.right)
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 1, y: 1)), current.down)
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 2, y: 2)), current.left)
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 1, y: 3)), current.top)
    }
    
    //X = CURRENT PLAYER
    // (0,0) (1,0) (2,0)
    // (0,1) (1,1) (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testGetSmartDirection() {
        let candidatePosition = Position(x: 1, y: 3)
        let possiblePositions = [candidatePosition]
        let directionHelper = DirectionHelper(position: player.position)
        let direction = directionHelper.getSmartDirection(previous: player.previous, possiblePositions: possiblePositions)!
        XCTAssertEqual(direction, candidatePosition)
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    // (0,1)   W   (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testIsWallOnBetween() {
        let findTargetPositionHelper = FindTargetPositionHelper()
        let invader = Position(x: 1, y: 0)
        let walls = [Position(x: 1, y: 1)]
        XCTAssert(findTargetPositionHelper.isWallOnBetween(position: player.position, target: invader, walls: walls))
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   W     W   (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testNotAccessibleNeutralInvader() {
        let invaders = [Invader(x: 1, y: 0, neutral: true)]
        let walls = [Position(x: 0, y: 1), Position(x: 1, y: 1)]
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: self.player.position, invaders: invaders, walls: walls)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: [], invaders: invaders, walls: walls, isValidPosition: isValidPosition)
        
        if  player.fire {
            let positions = findTargetPositionHelper.getNeutralInvaderPositions(descriptor: descriptor)
            let position = positionWithLessSteps(positions: positions)!
            XCTAssertEqual(position, Position(x: 1, y: 0))
        } else {
            XCTAssert(false)
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   W   (1,1)   W
    // (0,2)   X   (2,2)
    //   W     W     W
    func testEmptyPositionWithWalls() {
        let invaders = [Invader(x: 1, y: 0, neutral: true)]
        let walls = [Position(x: 0, y: 1), Position(x: 2, y: 1), Position(x: 0, y: 3), Position(x: 1, y: 3), Position(x: 2, y: 3)]
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: self.player.position, invaders: invaders, walls: walls)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: [], invaders: invaders, walls: walls, isValidPosition: isValidPosition)
        if let position = findTargetPositionHelper.getMagic(descriptor: descriptor) {
            XCTAssertEqual(position, Position(x: 1, y: 1))
        } else {
            XCTAssert(false)
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   W   (1,1)   W
    // (0,2)   X   (2,2)
    //   W     W     W
    func testEmptyPositionWithWalls2() {
        
        player = Player(id: UUID(),
                        name: "Alex",
                        position: Position(x: 1, y: 2),
                        previous: Position(x: 1, y: 1),
                        area: Area(y1: 0, x1: 0, y2: 3, x2: 2),
                        fire: true)
        let invaders = [Invader(x: 1, y: 0, neutral: true)]
        let walls = [Position(x: 0, y: 1), Position(x: 2, y: 1), Position(x: 0, y: 3), Position(x: 1, y: 3), Position(x: 2, y: 3)]
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: self.player.position, invaders: invaders, walls: walls)
        }
        
        let findTargetPositionHelper = FindTargetPositionHelper()
        let descriptor = FindTargetPositionDescriptor(player: player, players: [], invaders: invaders, walls: walls, isValidPosition: isValidPosition)
        if let position = findTargetPositionHelper.getMagic(descriptor: descriptor) {
            XCTAssertEqual(position, Position(x: 2, y: 2))
        } else {
            XCTAssert(false)
        }
    }
    
    
    
    func isValidPosition(position: Position, players: [Position] = [Position](), invaders: [Invader] = [Invader](), walls: [Position] = [Position]()) -> Bool {
        return !walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: position) }
    }
    
    func positionWithLessSteps(positions: [Position]) -> Position? {
        let playerPosition = player.position
        return positions.min { playerPosition.stepsTo(position: $0) < playerPosition.stepsTo(position: $1) }
    }
}

