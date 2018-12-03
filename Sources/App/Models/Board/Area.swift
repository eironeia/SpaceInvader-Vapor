import Foundation

protocol AreaProtocol {
    func getPositionsOfArea(without position: Position) -> [Position]
    func getVerticalPositions(without position: Position) -> [Position]
    func getHorizontalPositions(without position: Position) -> [Position]
}

struct Area: Codable, AreaProtocol {
    let y1: Int
    let x1: Int
    let y2: Int
    let x2: Int
    
    func getPositionsOfArea(without position: Position) -> [Position] {
        var positions = [Position]()
        let xrange = (x1...x2)
        let yrange = (y1...y2)
        xrange.forEach { xCoord in
            yrange.forEach { yCoord in
                if position.x != xCoord && position.y != yCoord { positions.append(Position(x: xCoord, y: yCoord)) }
            }
        }
        return positions
    }
    
    func getVerticalPositions(without position: Position) -> [Position] {
        var positions = [Position]()
        let yrange = (y1...y2)
        yrange.forEach { if position.y != $0 { positions.append(Position(x: position.x, y: $0)) } }
        return positions
    }
    
    func getHorizontalPositions(without position: Position) -> [Position] {
        var positions = [Position]()
        let xrange = (x1...x2)
        xrange.forEach { if position.x != $0 { positions.append(Position(x: $0, y: position.y)) } }
        return positions
    }
}
