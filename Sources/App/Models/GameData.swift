import Foundation

struct GameData: Codable {
    let game: Game
    let player: Player
    let board: Board
    let players: [Position]
    let invaders: [Invader]
}

struct Board: Codable {
    let size: Size
    let walls: [Position]
}

struct Size: Codable {
    let height: Int
    let width: Int
}

struct Position: Codable {
    let x: Int
    let y: Int
}

struct Game: Codable {
    let id: UUID
}

struct Invader: Codable {
    let y: Int
    let x: Int
    let neutral: Bool
}

struct Player: Codable {
    let id: UUID
    let name: String
    let position: Position
    let previous: Position
    let area: Area
    let fire: Bool
}

struct Area: Codable {
    let y1: Int
    let x1: Int
    let y2: Int
    let x2: Int
}

