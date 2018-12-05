import XCTest
@testable import App

// x1 = 0 y1 = 0
// x2 = 0 y2 = 3
//
// (0,0) (1,0) (2,0)
// (0,1) (1,1) (2,1)
// (0,2) (1,2) (2,2)
// (0,3) (1,3) (2,3)

class PlayerTests: XCTestCase {
    
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
}

//MARK: - getKillMove
extension PlayerTests {
    
    func getPlayerKillMoveDescriptor(players: [Position] = [Position](), invaders: [Invader] = [Invader](), walls: [Position] = [Position]()) -> PlayerKillMoveDescriptor {
        return PlayerKillMoveDescriptor(players: players, invaders: invaders, walls: walls)
    }
    
    //X = CURRENT PLAYER
    //   P     I   (2,0)
    // (0,1)   I   (2,1)
    // (0,2)   X     P
    // (0,3) (1,3) (2,3)
    func testKillInvadersAndPlayers() {
        let players = [Position(x: 0, y: 0), Position(x: 2, y: 2)]
        let invaders: [Invader] = [Invader(x: 1, y: 0, neutral: false), Invader(x: 1, y: 1, neutral: false)]
        let descriptor = getPlayerKillMoveDescriptor(players: players, invaders: invaders)
        if let move = player.getKillMove(descriptor: descriptor) {
            XCTAssert(move == Move(MoveTypes.fireRight.rawValue))
        }
    }
    
    //X = CURRENT PLAYER
    //   P     I   (2,0)
    // (0,1)   I   (2,1)
    // (0,2)   X     I
    // (0,3) (1,3) (2,3)
    func testKillInvadersPriority() {
        let players = [Position(x: 0, y: 0)]
        let invaders: [Invader] = [Invader(x: 1, y: 0, neutral: false), Invader(x: 1, y: 1, neutral: false), Invader(x: 2, y: 2, neutral: false)]
        let descriptor = getPlayerKillMoveDescriptor(players: players, invaders: invaders)
        if let move = player.getKillMove(descriptor: descriptor) {
            XCTAssert(move == Move(MoveTypes.fireUp.rawValue))
        }
    }
    
    //X = CURRENT PLAYER
    //   P     P   (2,0)
    // (0,1)   W   (2,1)
    // (0,2)   X     I
    // (0,3) (1,3) (2,3)
    func testKillAndWallsPriority() {
        let players = [Position(x: 0, y: 0), Position(x: 1, y: 0)]
        let invaders: [Invader] = [Invader(x: 1, y: 0, neutral: false), Invader(x: 1, y: 1, neutral: false), Invader(x: 2, y: 2, neutral: false)]
        let walls: [Position] = [Position(x: 1, y: 2)]
        let descriptor = getPlayerKillMoveDescriptor(players: players, invaders: invaders, walls: walls)
        if let move = player.getKillMove(descriptor: descriptor) {
            XCTAssert(move == Move(MoveTypes.fireRight.rawValue))
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0) (1,0) (2,0)
    // (0,1) (1,1) (2,1)
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testNotKillTarge() {
        let descriptor = getPlayerKillMoveDescriptor()
        if let _ = player.getKillMove(descriptor: descriptor) {
            XCTAssert(false)
        }
        else {
            XCTAssert(true)
        }
    }
}

//MARK: - getGoalPosition
extension PlayerTests {
    
    //X = CURRENT PLAYER
    //   I     I    NI
    // (0,1) (1,1) (2,1)
    // (0,2)   X     I
    // (0,3) (1,3) (2,3)
    func testNeutralInvaderGoalPosition() {
        let invaders = [Invader(x: 0, y: 0, neutral: false), Invader(x: 1, y: 0, neutral: false), Invader(x: 2, y: 0, neutral: true), Invader(x: 2, y: 2, neutral: false)]
        if  player.fire,
            let position = player.getNeutralInvaderPosition(invaders: invaders) {
            XCTAssertEqual(Position(x: 2, y: 0), position)
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

        if  let position = player.getInvaderPosition(invaders: invaders, isValidPosition: isValidPosition) {
            XCTAssertEqual(Position(x: 0, y: 2), position)
        }
    }
    
    //X = CURRENT PLAYER
    // (0,0)   I   (2,0)
    //   I   (1,1)   I
    // (0,2)   X   (2,2)
    // (0,3) (1,3) (2,3)
    func testEmptyPosition() {
        let invaders = [Invader(x: 1, y: 0, neutral: false), Invader(x: 0, y: 1, neutral: false), Invader(x: 2, y: 1, neutral: false)]
        let isValidPosition: (Position) -> Bool = { [unowned self] position in
            return self.isValidPosition(position: position, invaders: invaders)
        }
        if let position = player.getEmptyPosition(invaders: invaders, isValidPosition: isValidPosition) {
            XCTAssertEqual(position, Position.init(x: 1, y: 3))
        }
        
    }

    func isValidPosition(position: Position, players: [Position] = [Position](), invaders: [Invader] = [Invader](), walls: [Position] = [Position]()) -> Bool {
        return !walls.contains(position)
            && !players.contains(position)
            && !invaders.contains { $0.isNoNeutralInvaderOn(position: position) }
    }
}
