import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    router.post("name") { _ in
        return Credentials()
    }
    
    router.post("move") { _ -> Move in
        let movesType = MoveTypes.allCases
        let randomIndex = Int(arc4random_uniform(4))
        return Move(movesType[randomIndex].rawValue)
    }
}
