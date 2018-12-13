import Foundation

enum KillScore: Int {
    case player = 101
    case invader = 50
}

struct PlayerMoveDescriptor {
    let players: [Position]
    let invaders: [Invader]
    let walls: [Position]
    let pathFinder: AStarPathfinder
    let board: Board
    let area: Area
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
        if let goalPosition = getGoalPosition(descriptor: descriptor) {
            return DirectionHelper(position: position).getMove(to: goalPosition)
        } else {
            print("🚔🚔🚔🚔NOT SHORTED PATH FOUND THINK SOMETHING DUDE!🚔🚔🚔🚔")
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
        
        let scoreHelper = ScoreHelper(position: position)
        xrange.forEach {
            if position.x != $0 {
                scoreHelper.increaseScores(xPosition: $0, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
            }
        }
        
        yrange.forEach {
            if position.y != $0 {
                scoreHelper.increaseScores(yPosition: $0, descriptor: descriptor, scoresPerMoveTypes: &scoresPerMoveTypes)
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

//MARK: - PlayerGoalPosition
extension Player {
    func getGoalPosition(descriptor: PlayerMoveDescriptor) -> Position? {
        let findTargetHelper = FindTargetPositionHelper()
        let findTargetDescriptor = FindTargetPositionDescriptor(player: self, players: descriptor.players, invaders: descriptor.invaders, walls: descriptor.walls, area: descriptor.area, isValidPosition: descriptor.isValidPosition)
        var nextPositions = [[Position]]()
        
        //NEUTRAL INVADER
        let neutralInvaderPositions = findTargetHelper.getNeutralInvaderPositions(descriptor: findTargetDescriptor)
        if let shortestPaths = findTargetHelper.getShortestPaths(targets: neutralInvaderPositions, pathFinder: descriptor.pathFinder, descriptor: findTargetDescriptor) {
            nextPositions += shortestPaths
        }
        
        //INVADER
        if let invaderPositions = findTargetHelper.getInvaderPositions(descriptor: findTargetDescriptor),
            let shortestPaths = findTargetHelper.getShortestPaths(targets: invaderPositions, pathFinder: descriptor.pathFinder, descriptor: findTargetDescriptor) {
            nextPositions += shortestPaths
        }
        
        //PLAYER
        if let playerPosition = findTargetHelper.getPlayerPositions(descriptor: findTargetDescriptor),
            let shortestPaths = findTargetHelper.getShortestPaths(targets: playerPosition, pathFinder: descriptor.pathFinder, descriptor: findTargetDescriptor) {
            nextPositions += shortestPaths
        }
        
        //SHORT SHORTEST PATH
        if !nextPositions.isEmpty {
            print("Selected ✅:", nextPositions.min(by: { $0.count < $1.count })?.first ?? "-")
            return nextPositions.min(by: { $0.count < $1.count })?.first
        }
        
        if let emptyPosition = findTargetHelper.getEmptyPosition(descriptor: findTargetDescriptor) {
            print("Empty😶: \(emptyPosition)")
            return emptyPosition
        }
        else {
            print("🚨🚨🚨 RANDOM 🤪🤪🤪🤪")
            return Position(x: Int(descriptor.board.size.width/1), y: Int(descriptor.board.size.height/1))
        }
    }
}
