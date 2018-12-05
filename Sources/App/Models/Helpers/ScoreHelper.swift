import Foundation

fileprivate struct IncreaseXScoreDescriptor {
    let xPosition: Int
    let playerKillMoveDescriptor: PlayerKillMoveDescriptor
    var scoresPerMoveTypes: [MoveTypes: Int]
}

struct ScoreHelper {
    
    let position: Position
    
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
