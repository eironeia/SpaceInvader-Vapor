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
        print(area.x1, area.x2, area.y1, area.y2)
        guard fire else { return nil }
        let xrange = (area.x1...area.x2)
        let yrange = (area.y1...area.y2)
        let moveTypes: [MoveTypes] = [.up, .left, .down, .right]
        var scoresPerMoveTypes = moveTypes.reduce([MoveTypes: Int]()) { (result, movement) -> [MoveTypes: Int] in
            var result = result
            result[movement] = 0
            return result
        }
        
        for xPosition in xrange {
            if position.x != xPosition {
                increaseScores(xPosition: xPosition, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
        
        yrange.forEach {
            if position.y != $0 {
                increaseScores(yPosition: $0, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
        //TODO: Check before update if there is a wall between
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
            if descriptor.invaders.contains(where: { $0.x == xPosition && $0.y == position.y && !$0.neutral}) {
                increaseScores(movement: movement, score: KillScore.invader.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
    }
    
    func increaseScores(yPosition: Int, movement: MoveTypes, descriptor: PlayerKillMoveDescriptor, scoresPerMoveTypes: inout [MoveTypes: Int]) {
        if !position.isWallBetween(yPosition: yPosition, walls: descriptor.walls) {
            if descriptor.players.contains(where: { $0.y == yPosition && $0.x == position.x }) {
                increaseScores(movement: movement, score: KillScore.player.rawValue, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
            if descriptor.invaders.contains(where: { $0.y == yPosition && $0.x == position.x && !$0.neutral}) {
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
