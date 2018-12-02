import Foundation

struct PlayerMoveDescriptor {
    let goalPosition: Position
    let pathFinder: AStarPathfinder
}

struct PlayerKillMoveDescriptor {
    let players: [Position]
    let invaders: [Invader]
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
        let xrange = (area.x1...area.x2)
        let yrange = (area.y1...area.y2)
        
        var scoresPerMovement = Movement.allCases.reduce([Movement: Int]()) { (result, movement) -> [Movement: Int] in
            var result = result
            result[movement] = 0
            return result
        }
        
        xrange.forEach {
            if position.x != $0 {
                increaseScores(xPosition: $0, descriptor: descriptor, scoresPerMovement: &scoresPerMovement)
            }
        }
        
        yrange.forEach {
            if position.y != $0 {
                
            }
        }
    }
}

private extension Player {
    func increaseScores(xPosition: Int, descriptor: PlayerKillMoveDescriptor, scoresPerMovement: inout [Movement: Int]) {
        if xPosition < position.x {
            if descriptor.players.contains(where: { $0.x == xPosition && $0.y == position.y }) {
                if let score = scoresPerMovement[.left] {
                    scoresPerMovement[.left] = score + 100
                }
            }
            if descriptor.invaders.contains(where: { $0.x == xPosition && $0.y == position.y && !$0.neutral}) {
                if let score = scoresPerMovement[.left] {
                    scoresPerMovement[.left] = score + 50
                }
            }
        }
    }
    
    func increaseScores(yPosition: Int, scoresPerMovement: inout [Movement: Int]) {
        
    }
}
