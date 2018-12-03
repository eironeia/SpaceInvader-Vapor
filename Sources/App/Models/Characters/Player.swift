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
        print(fire)
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
        let weightedPositions = position.getWeightedPositions(area: area)
        print("Current: \(position)")
        if let neutralInvaderPosition = getNeutralInvaderPosition(weightedPositions: weightedPositions, invaders: descriptor.invaders) {
            print("Neutral invader position: \(neutralInvaderPosition)")
            return neutralInvaderPosition
        }
//        if let playerPosition = getPlayerPositionIfFire(weightedPositions: weightedPositions, players: descriptor.players) {
//            return playerPosition
//        }

//        if let noNeutralInvaderPosition = getNoNeutralInvaderPosition(weightedPositions: weightedPositions, invaders: descriptor.invaders) {
//            print("No neutral invader position:", noNeutralInvaderPosition)
//            return noNeutralInvaderPosition
//        }

        if let emptyPosition = getEmptyPosition(weightedPositions: weightedPositions, isValidPosition: descriptor.isValidPosition) {
            print("Empty position: \(emptyPosition)")
            return emptyPosition
        }
        print("No movement found")
        return nil
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
    func getNeutralInvaderPosition(weightedPositions: [WeightedPositon], invaders: [Invader]) -> Position? {
        return weightedPositions.first { weightedPosition -> Bool in
            let position = weightedPosition.position
            return invaders.contains(where: { $0.isNeutralInvaderOn(position: position) })
            }?.position
    }
    
    func getEmptyPosition(weightedPositions: [WeightedPositon], isValidPosition: (Position) -> Bool) -> Position? {
        return weightedPositions.first { weightedPosition -> Bool in
            let position = weightedPosition.position
            return isValidPosition(position)
        }?.position
    }
    
    func getPlayerPositionIfFire(weightedPositions: [WeightedPositon], players: [Position]) -> Position? {
        guard fire else { return nil }
        return weightedPositions.first { weightedPosition -> Bool in
            let position = weightedPosition.position
            return players.contains(where: { $0 == position })
            }?.position
    }
    
    func getNoNeutralInvaderPosition(weightedPositions: [WeightedPositon], invaders: [Invader]) -> Position? {
        print("No neutral invader position")
        guard fire else { return nil }
        print("Fire:", fire)
        return weightedPositions.first { weightedPosition -> Bool in
            let position = weightedPosition.position
            print("Getting no neutral...")
            let containsNoNeutral = invaders.contains(where: { $0.isNoNeutralInvaderOn(position: position) })
            print("Result:", containsNoNeutral)
            return containsNoNeutral
            }?.position
    }
    
    //Go to player if there is fire ON
    //Go to invader if there is fire ON
    
}
