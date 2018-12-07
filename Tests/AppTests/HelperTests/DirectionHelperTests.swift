import XCTest
import Foundation
@testable import App

class DirectionHelperTests: XCTestCase {
    
    let directionHelper = DirectionHelper(position: Position(x: 1, y: 2))
    
    func testGetMove() {
        XCTAssertEqual(directionHelper.getMove(to: Position(x: 1, y: 1)), Move.getMove(from: .up))
        XCTAssertEqual(directionHelper.getMove(to: Position(x: 1, y: 3)), Move.getMove(from: .down))
        XCTAssertEqual(directionHelper.getMove(to: Position(x: 0, y: 2)), Move.getMove(from: .left))
        XCTAssertEqual(directionHelper.getMove(to: Position(x: 2, y: 2)), Move.getMove(from: .right))
    }

    func testGetNewSameDirectionAsPrevious() {
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 0, y: 2)), Position(x: 2, y: 2))
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 1, y: 1)), Position(x: 1, y: 3))
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 1, y: 3)), Position(x: 1, y: 1))
        XCTAssertEqual(directionHelper.getNewSameDirectionAsPrevious(previous: Position(x: 2, y: 2)), Position(x: 0, y: 2))
        
    }
    
    func testGetSmartDirection() {
        let previous = Position(x: 0, y: 2)
        let possiblePositions = [Position(x: 1, y: 1), Position(x: 1, y: 3), Position(x: 2, y: 2)]
        XCTAssertEqual(directionHelper.getSmartDirection(previous: previous, possiblePositions: possiblePositions), Position(x: 2, y: 2))
        
    }
    
    func testGetSmartDirection2() {
        let previous = Position(x: 0, y: 2)
        let possiblePositions = [Position(x: 1, y: 1), Position(x: 1, y: 3)]
        XCTAssertEqual(directionHelper.getSmartDirection(previous: previous, possiblePositions: possiblePositions), Position(x: 1, y: 3))
    }
    
    func testGetNextClockPosition() {
        XCTAssertEqual(directionHelper.getNextClockPosition(candidate: Position(x: 2, y: 2)), directionHelper.position.down)
        XCTAssertEqual(directionHelper.getNextClockPosition(candidate: Position(x: 1, y: 3)), directionHelper.position.left)
        XCTAssertEqual(directionHelper.getNextClockPosition(candidate: Position(x: 1, y: 1)), directionHelper.position.right)
        XCTAssertEqual(directionHelper.getNextClockPosition(candidate: Position(x: 0, y: 2)), directionHelper.position.top)
    }
    
    //Previous: (0,2)
    //Current: (1,2)
    //Expected: (1,1)
    func testGetNextNoClockPosition() {
        // ->
        XCTAssertEqual(directionHelper.getNextNoClockPosition(candidate: Position(x: 2, y: 2)), directionHelper.position.top)
        XCTAssertEqual(directionHelper.getNextNoClockPosition(candidate: Position(x: 1, y: 3)), directionHelper.position.right)
        XCTAssertEqual(directionHelper.getNextNoClockPosition(candidate: Position(x: 1, y: 1)), directionHelper.position.left)
        XCTAssertEqual(directionHelper.getNextNoClockPosition(candidate: Position(x: 0, y: 2)), directionHelper.position.down)
    }
}
