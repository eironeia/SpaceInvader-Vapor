import Foundation

struct  FindTargetPositionDescriptor {
    let player: Player
    let players: [Position]
    let invaders: [Invader]
    let walls: [Position]
    let area: Area
    let isValidPosition: (Position) -> Bool
    
    init(player: Player, players: [Position] = [], invaders: [Invader] = [], walls: [Position] = [], area: Area, isValidPosition: @escaping (Position) -> Bool) {
        self.player = player
        self.players = players
        self.invaders = invaders
        self.walls = walls
        self.area = area
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
        if let exitWallPosition = getExitWallPosition(descriptor: descriptor) {
            return exitWallPosition
        } else {
            return directionHelper.getSmartDirection(previous: descriptor.player.previous, possiblePositions: emptyPositions)
        }
    }
    
    func getExitWallPosition(descriptor: FindTargetPositionDescriptor) -> Position? {
        let directionHelperPrevious = DirectionHelper(position: descriptor.player.previous)
        let directionHelper = DirectionHelper(position: descriptor.player.position)
        let newDirection = directionHelper.getNewSameDirectionAsPrevious(previous: descriptor.player.previous)
        let previousNoClock = directionHelperPrevious.getNextNoClockPosition(candidate: descriptor.player.position)
        let positionNoClock = directionHelper.getNextNoClockPosition(candidate: newDirection)
        guard descriptor.walls.contains(where: { $0 == previousNoClock }),
            descriptor.isValidPosition(positionNoClock),
            descriptor.player.isPositionOnArea(position: positionNoClock) else {
               return nil
        }
        return positionNoClock
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
        //Get positions where I can be killed
        let iCanBeKilledPositions = selfkillPoistion(descriptor: descriptor)
        //Remove from possible moves of current player positions which are potentially dangerous
        let notPossibleInvaderPosition = emptyPositions.filter { !possibleInvadersNextPositions.contains($0) }
        let extremeCase = notPossibleInvaderPosition.filter { !iCanBeKilledPositions.contains($0) }
        print("1.\(emptyPositions), 2. \(notPossibleInvaderPosition), 3.\(extremeCase), 4.\(iCanBeKilledPositions)")
        if !extremeCase.isEmpty { return extremeCase }
        if !notPossibleInvaderPosition.isEmpty { return notPossibleInvaderPosition }
        if !emptyPositions.isEmpty { return emptyPositions }
        return emptyPositions
    }
}

private extension FindTargetPositionHelper {
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
    
    func selfkillPoistion(descriptor: FindTargetPositionDescriptor) -> [Position] {
        let position = descriptor.player.position
        return descriptor.players.reduce([]) { (result, playerPosition) -> [Position] in
            var result = result
            if playerPosition.x != position.x && playerPosition.y == position.y {
                let xrange = (descriptor.area.x1...descriptor.area.x2)
                xrange.forEach { result.append(Position(x: $0, y: playerPosition.y)) }
            } else if playerPosition.x == position.x && playerPosition.y != position.y {
                let yrange = (descriptor.area.y1...descriptor.area.y2)
                yrange.forEach { result.append(Position(x: playerPosition.x, y: $0)) }
            }
            return result
        }
    }
}
