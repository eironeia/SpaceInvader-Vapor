import Foundation

struct Area: Codable {
    let y1: Int
    let x1: Int
    let y2: Int
    let x2: Int
    
    func getPositionsOfArea() -> [Position] {
        var positions = [Position]()
        let xrange = (x1...x2)
        let yrange = (y1...y2)
        xrange.forEach { xCoord in
            yrange.forEach { yCoord in
                positions.append(Position(x: xCoord, y: yCoord))
            }
        }
        return positions
    }
}
