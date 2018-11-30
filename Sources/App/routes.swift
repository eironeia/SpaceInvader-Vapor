import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    let gameController = GameController()
    try router.register(collection: gameController)
}


struct MockData {
    
    func getGameData() -> GameData? {
        let directory = DirectoryConfig.detect()
        let configDir = "Sources/App/MockData"
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: directory.workDir)
                .appendingPathComponent(configDir, isDirectory: true)
                .appendingPathComponent("GameData.json", isDirectory: false))
            return try JSONDecoder().decode(GameData.self, from: data)
        } catch {
            return nil
        }
    }
}
