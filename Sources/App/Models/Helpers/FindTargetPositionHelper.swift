import Foundation

struct  FindTargetPositionDescriptor {
    let player: Player
    let players: [Position]
    let invaders: [Invader]
    let walls: [Position]
    let isValidPosition: (Position) -> Bool
    
    init(player: Player, players: [Position] = [], invaders: [Invader] = [], walls: [Position] = [], isValidPosition: @escaping (Position) -> Bool) {
        self.player = player
        self.players = players
        self.invaders = invaders
        self.walls = walls
        self.isValidPosition = isValidPosition
    }
}

struct FindTargetPositionHelper {
    
    func getNeutralInvaderPositions(descriptor: FindTargetPositionDescriptor) -> [Position] {
        return descriptor.invaders
            .filter { $0.neutral }
            .map { $0.position }
    }
    
    func getInvaderPositions(descriptor: FindTargetPositionDescriptor) -> [Position]? {
        guard descriptor.player.fire else { return nil }
        let neutralInvadersPosition = descriptor.invaders
            .filter { !$0.neutral }
            .map { $0.position }
        return getKillTargetPosition(target: neutralInvadersPosition, descriptor: descriptor)
    }
    
    func getPlayerPositions(descriptor: FindTargetPositionDescriptor) -> [Position]? {
        guard descriptor.player.fire else { return nil }
        return getKillTargetPosition(target: descriptor.players, descriptor: descriptor)
    }
    
    func getEmptyPosition(descriptor: FindTargetPositionDescriptor) -> Position? {
        guard let emptyPositions = getEmptyPositions(descriptor: descriptor) else { return nil }
        let directionHelper = DirectionHelper(position: descriptor.player.position)
        return directionHelper.getSmartDirection(previous: descriptor.player.previous, possiblePositions: emptyPositions)
    }
    
    //Delete?
    func updateNextPositions(pathFinder: AStarPathfinder, current: Position, goalPosition: Position, nextPositions: inout [Position]) {
        if let nextPosition = getNextPosition(pathFinder: pathFinder, current: current, goalPosition: goalPosition) {
            nextPositions.append(nextPosition)
        }
    }
    
    func getShortestPaths(targets: [Position], pathFinder: AStarPathfinder, descriptor: FindTargetPositionDescriptor) -> [[Position]]? {
        guard !targets.isEmpty else { return nil }
        return targets.reduce([]) { (positions, position) -> [[Position]] in
            var positions = positions
            if let shortestPath = pathFinder.shortestPath(current: descriptor.player.position, goal: position) {
                positions.append(shortestPath)
            }
            return positions
        }
    }
    
    func isWallOnBetween(position: Position, target: Position, walls: [Position]) -> Bool {
        
        if position.x == target.x {
            var range: [Int] = []
            
            if position.y > target.y { //TOP
                range = Array(target.y...position.y)
            } else {                   //DOWN
                range = Array(position.y...target.y)
            }
            
            for y in range {
                let position = Position(x: position.x, y: y)
                if walls.contains(position) {
                    return true
                }
            }
        }
        
        if position.y == target.y {
            var range: [Int]!
            if position.x > target.x {   //LEFT
                range = Array(target.x...position.x)
            } else {                     //RIGHT
                range = Array(position.x...target.x)
            }
            
            for x in range {
                let position = Position(x: x, y: position.y)
                if walls.contains(position) {
                    return true
                }
            }
        }
        return false
    }
}

private extension FindTargetPositionHelper {
    func getEmptyPositions(descriptor: FindTargetPositionDescriptor) -> [Position]? {
        //Get current player possible moves which valids positions
        let emptyPositions = descriptor.player.position.adjacentPositions().filter(descriptor.isValidPosition)
        //Get invaders possible moves + current position
        let possibleInvadersNextPositions = descriptor.invaders.reduce([]) { (positions, invader) -> [Position] in
            var positions = positions
            if !invader.neutral {
                positions += invader.position.adjacentPositions()
                positions.append(invader.position)
            }
            return positions
        }
        //Remove from possible moves of current player positions which are potentially dangerous
        let notPossibleInvaderPosition = emptyPositions.filter { !possibleInvadersNextPositions.contains($0) }
        if !notPossibleInvaderPosition.isEmpty { return notPossibleInvaderPosition }
        if !emptyPositions.isEmpty { return emptyPositions }
        return emptyPositions
    }
    
    func getKillTargetPosition(target: [Position], descriptor: FindTargetPositionDescriptor) -> [Position] {
        //Positions where target can be kill
        let killTargetPositions = target.reduce([], { (killPositions, position) -> [Position] in
            var killPositions = killPositions
            killPositions += position.getKillPositions(area: descriptor.player.area)
                //Remove positions where there is a wall between target and position on killing
                .filter {
                    descriptor.isValidPosition($0)
                        && $0 != descriptor.player.position
                        && !isWallOnBetween(position: $0, target: position, walls: descriptor.walls)
            }
            return killPositions
        })
        return killTargetPositions
    }
    
    func getNextPosition(pathFinder: AStarPathfinder, current: Position, goalPosition: Position) -> Position? {
        let shortestPath = pathFinder.shortestPath(current: current, goal: goalPosition)
        return shortestPath?.first
    }
}
