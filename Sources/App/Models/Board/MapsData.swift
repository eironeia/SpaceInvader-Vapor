import Foundation

struct WallsDataDescriptor {
    let gameID: String
    let walls: [Position]
}

struct MapsDataCandidatePositionsDescriptor {
    let gameID: String
    let playerPosition: Position
    let board: Board
    let isValidPosition: (Position) -> Bool
    let isInBoard: (Position) -> Bool
}

struct CandidatePositions {
    var index: Int
    var candidates: [Position]
}

class MapsData {
    static let shared = MapsData()
    private var walls = [String: Set<Position>]()
    private var candidatePositions = [String: CandidatePositions]()
    
    func getWalls(descriptor: WallsDataDescriptor) -> [Position] {
        guard let savedWallsPositions = walls[descriptor.gameID] else {
            walls[descriptor.gameID] = Set(descriptor.walls)
            return descriptor.walls
        }
        walls[descriptor.gameID] = savedWallsPositions.union(Set(descriptor.walls))
        return Array(savedWallsPositions)
    }
    
    func getCandidatePosition(descriptor: MapsDataCandidatePositionsDescriptor) -> Position? {
        if var candidatePositions = candidatePositions[descriptor.gameID] {
            var index = candidatePositions.index
            let currentCandidate = candidatePositions.candidates[index]
            if currentCandidate == descriptor.playerPosition {
                index = candidatePositions.candidates.count - 1 == index ? 0 : index + 1
                self.candidatePositions[descriptor.gameID]?.index = index
                return candidatePositions.candidates[index]
            }
            return currentCandidate
        } else {
            guard let candidatePostions = getCandidatePositions(descriptor: descriptor) else { return nil }
            self.candidatePositions[descriptor.gameID] = candidatePostions
            return candidatePostions.candidates[candidatePostions.index]
        }
    }
    
    func resetStuff() {
        walls = [:]
        candidatePositions = [:]
    }
}

private extension MapsData {
    
    func getCandidatePositions(descriptor: MapsDataCandidatePositionsDescriptor) -> CandidatePositions? {
        let boardWidth = descriptor.board.size.width
        let boardHeight = descriptor.board.size.height
        let xCenter = Int(boardWidth/2)
        let xQuarterLeft = Int(boardWidth/4)
        let xQuarterRight = Int(3*boardWidth/4)
        let yCenter = Int(boardHeight/2)
        let yQuarterTop = Int(boardHeight/4)
        let yQuarterBottom = Int(3*boardHeight/4)
        guard let centerPosition = getValidPosition(candidate: Position(x: xCenter, y: yCenter), descriptor: descriptor),
            let firstQuarterPosition = getValidPosition(candidate: Position(x: xQuarterLeft, y: yQuarterTop), descriptor: descriptor),
            let secondQuarterPosition = getValidPosition(candidate: Position(x: xQuarterRight, y: yQuarterTop), descriptor: descriptor),
            let thirdQuarterPosition = getValidPosition(candidate: Position(x: xQuarterLeft, y: yQuarterBottom), descriptor: descriptor),
            let fourthQuarterPosition = getValidPosition(candidate: Position(x: xQuarterRight, y: yQuarterBottom), descriptor: descriptor) else {
                return nil
        }
        return CandidatePositions(index: 0,
                                  candidates: [firstQuarterPosition,
                                               centerPosition,
                                               secondQuarterPosition,
                                               centerPosition,
                                               thirdQuarterPosition,
                                               fourthQuarterPosition])
    }
    
    func getValidPosition(candidate: Position, descriptor: MapsDataCandidatePositionsDescriptor) -> Position? {
        if descriptor.isValidPosition(candidate) { return candidate }
        for distance in 1...10 {
            if let candidatePosition = getPositionsWithDistance(position: candidate, distance: distance, descriptor: descriptor) {
                return candidatePosition
            }
        }
        print("Not found doable path")
        return nil
    }
    
    func getPositionsWithDistance(position: Position, distance: Int, descriptor: MapsDataCandidatePositionsDescriptor) -> Position? {
        return [
            Position(x: position.x+distance, y: position.y),
            Position(x: position.x-distance, y: position.y),
            Position(x: position.x, y: position.y+distance),
            Position(x: position.x, y: position.y-distance),
            Position(x: position.x+distance, y: position.y+distance),
            Position(x: position.x+distance, y: position.y-distance),
            Position(x: position.x-distance, y: position.y+distance),
            Position(x: position.x-distance, y: position.y-distance)
            ].first(where: { descriptor.isValidPosition($0) && descriptor.isInBoard($0) })
    }
}
