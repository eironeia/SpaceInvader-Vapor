import Foundation

enum KillScore: Int {
    case player = 101
    case invader = 50
}

struct PlayerMoveDescriptor {
    let players: [Position]
    let invaders: [Invader]
    let pathFinder: AStarPathfinder
    let isValidPosition: (Position) -> Bool
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
    
    func isPositionOnArea(position: Position) -> Bool {
        return position.x >= area.x1 && position.y >= area.y1 && position.x <= area.x2 && position.y <= area.y2
    }
    
    func getMove(descriptor: PlayerMoveDescriptor) -> Move {
        print("Getting next move with shortest path... 🥳")
        if let goalPosition = getGoalPosition(descriptor: descriptor) {
            print("😎¡CALCULATED!🤓")
            return position.getMove(to: goalPosition)
        } else {
            print("NOT SHORTED PATH FOUND THINK SOMETHING DUDE!🚨🤯")
            return Move(MoveTypes.left.rawValue)
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
    func getGoalPosition(descriptor: PlayerMoveDescriptor) -> Position? {
        
        if let neutralInvaderPosition = getNeutralInvaderPosition(invaders: descriptor.invaders),
            let nextPosition = getNextPosition(pathFinder: descriptor.pathFinder, goalPosition: neutralInvaderPosition) {
            print("GOING TO 👻")
            return nextPosition
        }
        
        if let playerPosition = getPlayerPosition(players: descriptor.players, isValidPosition: descriptor.isValidPosition),
            let nextPosition = getNextPosition(pathFinder: descriptor.pathFinder, goalPosition: playerPosition) {
            print("GOING TO 🚀")
            return nextPosition
        }
        
        if let noNeutralInvaderPosition = getInvaderPosition(invaders: descriptor.invaders, isValidPosition: descriptor.isValidPosition),
            let nextPosition = getNextPosition(pathFinder: descriptor.pathFinder, goalPosition: noNeutralInvaderPosition) {
            print("GOING TO 👾")
            return nextPosition
        }
        
        print("RANDOM 🤪")
        return Position(x: Int(area.x2/(area.x1 == 0 ? 1 : area.x1)), y: Int(area.y2/(area.y1 == 0 ? 1 : area.y1)))
    }
    
    private func getNextPosition(pathFinder: AStarPathfinder, goalPosition: Position) -> Position? {
        let shortestPath = pathFinder.shortestPath(current: position, goal: goalPosition)
        return shortestPath?.first
    }
    
    func getInvaderPosition(invaders: [Invader], isValidPosition: (Position) -> Bool) -> Position? {
        guard fire else { return nil }
        let neutralInvadersPosition = invaders.filter { !$0.neutral }.map { $0.position }
        return getKillTargetPosition(target: neutralInvadersPosition, isValidPosition: isValidPosition)
    }
    
    func getNeutralInvaderPosition(invaders: [Invader]) -> Position? {
        return invaders.filter { return $0.neutral }.min { position.stepsTo(position: $0.position) < position.stepsTo(position: $1.position) }?.position
    }
    
    func getPlayerPosition(players: [Position], isValidPosition: (Position) -> Bool) -> Position? {
        guard fire else { return nil }
        return getKillTargetPosition(target: players, isValidPosition: isValidPosition)
    }
    
    //Dodge player shot if not fire
    func dogePlayerPosition() -> Position? {
        return nil
    }
    
    //Move away of aliens & players
    
    //HELPER
    private func getKillTargetPosition(target: [Position], isValidPosition: (Position) -> Bool) -> Position? {
        var killPositions = [Position]()
        target.forEach {
            killPositions += $0.getKillPositions(area: area)
        }
        return killPositions.filter(isValidPosition).min { return position.stepsTo(position: $0) < position.stepsTo(position: $1) }
    }
}
