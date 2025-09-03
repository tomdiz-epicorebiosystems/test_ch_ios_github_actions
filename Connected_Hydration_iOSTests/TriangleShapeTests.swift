//
//  TriangleShapeTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
@testable import Connected_Hydration_iOS

class TriangleShapeTests: XCTestCase {
    
    func testPathInRect() {
        let triangle = Triangle()
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        let path = triangle.path(in: rect)
        
        XCTAssertEqual(path.currentPoint, CGPoint(x: rect.minX, y: rect.maxY))
    }
    
    func testPathInRectWithNegativeValues() {
        let triangle = Triangle()
        let rect = CGRect(x: -50, y: -50, width: 100, height: 100)
        let path = triangle.path(in: rect)
        
        XCTAssertEqual(path.currentPoint, CGPoint(x: rect.minX, y: rect.maxY))
    }
    
    func testPathInRectWithZeroWidth() {
        let triangle = Triangle()
        let rect = CGRect(x :0,y :0,width :0,height :100)
        let path = triangle.path(in :rect)
        
        XCTAssertEqual(path.currentPoint,CGPoint(x :rect.minX,y :rect.maxY))
    }
    
    func testPathInRectWithZeroHeight() {
        let triangle = Triangle()
        let rect = CGRect(x: 0, y: 0, width: 100, height: 0)
        let path = triangle.path(in: rect)
        
        XCTAssertEqual(path.currentPoint, CGPoint(x: rect.minX, y: rect.maxY))
    }
    
    func testPathInRectWithNegativeWidthAndHeight() {
        let triangle = Triangle()
        let rect = CGRect(x: -50, y: -50, width: -100, height: -100)
        let path = triangle.path(in: rect)
        
        XCTAssertEqual(path.currentPoint, CGPoint(x: rect.minX, y: rect.maxY))
    }
    
}
