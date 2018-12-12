import Foundation

struct MoveData {
    let move: Move
    let position: Position
}

class MovesStack {
    static let shared = MovesStack()
    private var movements: [MoveData] = [] {
        didSet {
            print("Movements count:", movements.count)
        }
    }
    private var timer: Timer?
    
    private init() {}
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(resetMovements), userInfo: nil, repeats: false)
    }
    
    func addMovement(movement: MoveData) {
        movements.append(movement)
        timer?.invalidate()
        startTimer()
    }
    
    ///FOR TESTING PURPOSES
    @objc
    func resetMovements() {
        movements = []
    }
    
    var shouldCheckForDodge: Bool {
        if movements.count > 2 {
            let last1Index = movements.count - 1
            let last2Index = movements.count - 2
            let last3Index = movements.count - 3
            return (movements[last1Index], movements[last2Index]) == (movements[last2Index], movements[last3Index])
        }
        return false
    }
}
