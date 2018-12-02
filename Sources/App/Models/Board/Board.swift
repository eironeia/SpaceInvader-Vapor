import Foundation

struct Board: Codable {
    let size: Size
    let walls: [Position]
}
