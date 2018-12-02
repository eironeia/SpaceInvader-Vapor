import Foundation

protocol PathFinderDataSource: class {
    func possibleNextPositions(from position: Position) -> [Position]
    func costOfNextPosition(current: Position, adjacent: Position) -> Int
}

class AStarPathfinder {
    
    weak var datasource: PathFinderDataSource!
    
    func shortestPath(current: Position, goal: Position) -> [Position]? {
        
        guard let datasource = self.datasource else { return nil }
        var closedSteps = Set<ShortestPathStep>()
        var openSteps = [ShortestPathStep(position: current)]

        while !openSteps.isEmpty {
            let currentStep = openSteps.remove(at: 0)
            closedSteps.insert(currentStep)
            
            if currentStep.position == goal {
                return convertStepsToShortestPath(lastStep: currentStep)
            }

            let adjacentPositions = datasource.possibleNextPositions(from: currentStep.position)
            for tile in adjacentPositions {
                let step = ShortestPathStep(position: tile)
                if closedSteps.contains(step) { continue }
                let moveCost = datasource.costOfNextPosition(current: currentStep.position, adjacent: step.position)
                if let existingIndex = openSteps.firstIndex(of: step) {
                    let step = openSteps[existingIndex]
                    if currentStep.gScore + moveCost < step.gScore {
                        step.setParent(parent: currentStep, withMoveCost: moveCost)
                        openSteps.remove(at: existingIndex)
                        insertStep(step: step, inOpenSteps: &openSteps)
                    }
                } else {
                    step.setParent(parent: currentStep, withMoveCost: moveCost)
                    step.hScore = highScoreFromPosition(current: step.position, goal: goal)
                    insertStep(step: step, inOpenSteps: &openSteps)
                }
            }
        }
        return nil
    }
    
    private func insertStep(step: ShortestPathStep, inOpenSteps openSteps: inout [ShortestPathStep]) {
        openSteps.append(step)
        openSteps.sort { $0.fScore <= $1.fScore }
    }
    
    func highScoreFromPosition(current: Position, goal: Position) -> Int {
        return abs(goal.x - current.x) + abs(goal.y - current.y)
    }
    
    private func convertStepsToShortestPath(lastStep: ShortestPathStep) -> [Position] {
        var shortestPath = [Position]()
        var currentStep = lastStep
        while let parent = currentStep.parent { // if parent is nil, then it is our starting step, so don't include it
            shortestPath.insert(currentStep.position, at: 0)
            currentStep = parent
        }
        return shortestPath
    }
}
