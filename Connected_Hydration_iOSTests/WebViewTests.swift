//
//  WebViewTests.swift
//  Connected_Hydration_iOSTests
//
//  Created by Thomas DiZoglio on 10/11/23.
//

import XCTest
import WebKit
@testable import Connected_Hydration_iOS

class WebViewTests: XCTestCase {
    
    var webView: WebView!
    
    override func setUp() {
        super.setUp()
        webView = WebView(url: URL(string: "https://www.google.com")!)
    }
    
    override func tearDown() {
        webView = nil
        super.tearDown()
    }
    
    func testUpdateUIViewWithInvalidURL() {
        let uiView = WKWebView()
        
        XCTAssertNil(uiView.url)
    }
    
    func testLoadRequest() {
        let uiView = WKWebView()
        
        let request = URLRequest(url: URL(string: "https://www.google.com")!)
        
        uiView.load(request)
        
        XCTAssertEqual(uiView.url?.absoluteString, "https://www.google.com/")
    }
    
}
