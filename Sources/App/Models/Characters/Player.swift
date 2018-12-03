import Foundation

enum KillScore: Int {
    case player = 101
    case invader = 50
}

struct PlayerMoveDescriptor {
    let goalPosition: Position
    let pathFinder: AStarPathfinder
}

struct PlayerKillMoveDescriptor {
    let players: [Position]
    let invaders: [Invader]
    let walls: [Position]
}

struct PlayerGoalPositionDescriptor {
    let players: [Position]
    let invaders: [Invader]
    let pathFinder: AStarPathfinder
    let isValidPosition: (Position) -> Bool
}

struct Player: Codable {
    let id: UUID
    let name: String
    let position: Position
    let previous: Position
    let area: Area
    let fire: Bool
    
    func getMove(descriptor: PlayerMoveDescriptor) -> Move {
        let shortestPath = descriptor.pathFinder.shortestPath(current: position, goal: descriptor.goalPosition)
        if let shortestPath = shortestPath,
            let nextPosition = shortestPath.first {
            return position.getMove(to: nextPosition)
        } else {
            return Move(MoveTypes.up.rawValue)
        }
    }
    
    func getKillMove(descriptor: PlayerKillMoveDescriptor) -> Move? {
        guard fire else { return nil }
        let xrange = (area.x1...area.x2)
        let yrange = (area.y1...area.y2)
        let moveTypes: [MoveTypes] = MoveTypes.movements
        var scoresPerMoveTypes = moveTypes.reduce([MoveTypes: Int]()) { (result, movement) -> [MoveTypes: Int] in
            var result = result
            result[movement] = 0
            return result
        }
        
        xrange.forEach {
            if position.x != $0 {
                increaseScores(xPosition: $0, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
        
        yrange.forEach {
            if position.y != $0 {
                increaseScores(yPosition: $0, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
        
        let highScore = scoresPerMoveTypes.max { a, b in a.value < b.value }
        guard let moveType = highScore?.key,
            highScore?.value != 0 else { return nil }
        
        switch moveType {
        case .up: return Move.getMove(from: .fireUp)
        case .left: return Move.getMove(from: .fireLeft)
        case .down: return Move.getMove(from: .fireDown)
        case .right: return Move.getMove(from: .fireRight)
        default: return nil
        }
    }
    
    func getGoalPosition(descriptor: PlayerGoalPositionDescriptor) -> Position? {
        
        print("Fire:",fire)
        
        if let neutralInvaderPosition = getNeutralInvaderPosition(invaders: descriptor.invaders, pathFinder: descriptor.pathFinder) {
            print("Finding Neutral Invader \(neutralInvaderPosition)")
            return neutralInvaderPosition
        }
        
//        if let emptyPosition = getEmptyPosition(isValidPosition: descriptor.isValidPosition) {
//            print("Going to empty position \(emptyPosition)")
//            return emptyPosition
//        }
        
//        if let noNeutralInvaderPosition = getNoNeutralInvaderPosition(invaders: descriptor.invaders, pathFinder: descriptor.pathFinder) {
//            print("NO NEUTRAL WAY")
//            return noNeutralInvaderPosition
//        }
        
        print("Going random position")
        return Position(x: 1, y: 1)
        //        let shortestPathToPlayers = descriptor.players.compactMap { descriptor.pathFinder.shortestPath(current: position, goal: $0) }
    }
}

//MARK: - PlayerScore
private extension Player {
    func increaseScores(xPosition: Int, descriptor: PlayerKillMoveDescriptor, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if xPosition < position.x {
            increaseScores(xPosition: xPosition,
                           movement: .left,
                           descriptor: descriptor,
                           scoresPerMoveTypes: &scoresPerMoveTypes)
        } else {
            increaseScores(xPosition: xPosition,
                           movement: .right,
                           descriptor: descriptor,
                           scoresPerMoveTypes: &scoresPerMoveTypes)
        }
    }
    
    func increaseScores(yPosition: Int, descriptor: PlayerKillMoveDescriptor, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if yPosition < position.y {
            increaseScores(yPosition: yPosition,
                           movement: .up,
                           descriptor: descriptor,
                           scoresPerMoveTypes: &scoresPerMoveTypes)
        } else {
            increaseScores(yPosition: yPosition,
                           movement: .down,
                           descriptor: descriptor,
                           scoresPerMoveTypes: &scoresPerMoveTypes)
        }
    }
    
    func increaseScores(xPosition: Int, movement: MoveTypes, descriptor: PlayerKillMoveDescriptor, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if !position.isWallBetween(xPosition: xPosition, walls: descriptor.walls) {
            if descriptor.players.contains(where: { $0.x == xPosition && $0.y == position.y }) {
                increaseScores(movement: movement, score: KillScore.player.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
            if descriptor.invaders.contains(where: { $0.isNoNeutralInvaderOn(position: Position(x: xPosition, y: position.y))}) {
                increaseScores(movement: movement, score: KillScore.invader.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
    }
    
    func increaseScores(yPosition: Int, movement: MoveTypes, descriptor: PlayerKillMoveDescriptor, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if !position.isWallBetween(yPosition: yPosition, walls: descriptor.walls) {
            if descriptor.players.contains(where: { $0.y == yPosition && $0.x == position.x }) {
                increaseScores(movement: movement, score: KillScore.player.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
            if descriptor.invaders.contains(where: { $0.isNoNeutralInvaderOn(position: Position(x: position.x, y: yPosition))}) {
                increaseScores(movement: movement, score: KillScore.invader.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
    }
    
    func increaseScores(movement: MoveTypes, score: Int, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if let currentScore = scoresPerMoveTypes[movement] {
            scoresPerMoveTypes[movement] = currentScore + score
        }
    }
}

//MARK: - PlayerGoalPosition
private extension Player {
    func getNeutralInvaderPosition(invaders: [Invader], pathFinder: AStarPathfinder) -> Position? {
        return invaders.filter { $0.neutral }.min { position.distanceTo(position: $0.position) < position.distanceTo(position: $1.position) }?.position
    }
    
    func getEmptyPosition(isValidPosition: (Position) -> Bool) -> Position? {
        return area.getPositionsOfArea(without: position).filter { $0 != previous }.min { position.distanceTo(position: $0) < position.distanceTo(position: $1) }
    }
    
    func getPlayerPositionIfFire(players: [Position], pathFinder: AStarPathfinder) -> Position? {
        guard fire else { return nil }
        let shortestPathToPlayer = players.compactMap { pathFinder.shortestPath(current: position, goal: $0) }
        return shortestPathToPlayer.min { $0.count < $1.count }?.first
    }
    
    func getNoNeutralInvaderPosition(invaders: [Invader], pathFinder: AStarPathfinder) -> Position? {
        print("Fire: ", fire)
        guard fire else { return nil }
        return Position(x: 1, y: 1)
        
//        var killPositionsInvaders = [Position]()
//        let neutralsInvaders = invaders.filter { !$0.neutral }
//        neutralsInvaders.forEach {
//            killPositionsInvaders += $0.position.getKillPositions(area: area)
//        }
//        return killPositionsInvaders.min { $0.distanceTo(position: position) < $1.distanceTo(position: position) }
        
        
//        var killPositionsInvaders = [Position]()
//        invaders.filter { !$0.neutral }.forEach {
//            killPositionsInvaders += $0.position.getKillPositions(area: area)
//        }
//        return killPositionsInvaders.compactMap { pathFinder.shortestPath(current: position, goal: $0) }.min { $0.count < $1.count }?.first
    }
}
