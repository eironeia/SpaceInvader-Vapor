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
        let shortestPath = descriptor.pathFinder.shortestPath(current: position, goal: descriptor.goalPosition) //Add multiple options first neutral invaders, etc. checking for multiple options paths
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
        
        if let neutralInvadrPosition = getNeutralInvaderPosition(invaders: descriptor.invaders) {
            return neutralInvadrPosition
        }
        
        if let noNeutralInvaderPosition = getInvaderPosition(invaders: descriptor.invaders, isValidPosition: descriptor.isValidPosition) {
            return noNeutralInvaderPosition
        }
        
        return Position(x: 1, y: 1)
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
extension Player {
    func getInvaderPosition(invaders: [Invader], isValidPosition: (Position) -> Bool) -> Position? {
        let neutralInvaders = invaders.filter { !$0.neutral }
        var killPositionsNeutralInvader = [Position]()
        neutralInvaders.forEach {
            killPositionsNeutralInvader += $0.getKillPositions(area: area)
        }
        killPositionsNeutralInvader = killPositionsNeutralInvader.filter(isValidPosition)
        killPositionsNeutralInvader.forEach{ print($0) }
        return killPositionsNeutralInvader.min { return position.stepsTo(position: $0) < position.stepsTo(position: $1) }
    }
    
    func getNeutralInvaderPosition(invaders: [Invader]) -> Position? {
        return invaders.filter { return $0.neutral }.min { position.stepsTo(position: $0.position) < position.stepsTo(position: $1.position) }?.position
    }

//    //LATER?
//    func getEmptyPosition(isValidPosition: (Position) -> Bool) -> Position? {
//        return area.getPositionsOfArea(without: position).filter { $0 != previous }.min { position.distanceTo(position: $0) < position.distanceTo(position: $1) }
//    }
//
//    func getPlayerPositionIfFire(players: [Position], pathFinder: AStarPathfinder) -> Position? {
//        guard fire else { return nil }
//        let shortestPathToPlayer = players.compactMap { pathFinder.shortestPath(current: position, goal: $0) } //WE SHOUDN'T CALL A SHORTEST PATH
//        return shortestPathToPlayer.min { $0.count < $1.count }?.first
//    }
//
}
