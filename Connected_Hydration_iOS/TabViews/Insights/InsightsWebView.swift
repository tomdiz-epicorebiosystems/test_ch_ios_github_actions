//
//  InsightsWebView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/19/24.
//

import SwiftUI
import WebKit
import KeychainAccess

struct InsightsWebView: UIViewRepresentable {

    @EnvironmentObject var modelData: ModelData

    @Binding var url: URL
    @Binding var prevUrl : URL
    @Binding var isNetworkConnected : Bool
    @Binding var isInsightsWebViewPresented : Bool
    
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        let parent: InsightsWebView
        
        init(_ parent: InsightsWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // This injection stops users from selecting text in webview
            let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
            webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)
            /*
            print("Done loading...Dump HTML")
            webView.evaluateJavaScript("document.body.innerHTML", completionHandler: { result, error in
                if let html = result as? String {
                        print(html)
                    }
                })
            */
        }
    }

    func makeCoordinator() -> InsightsWebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let keychain = Keychain(service: keychainAppBundleId)
        let currentToken = keychain["access_token"] ?? ""

        //print("***** Set Cookies **********")
        //print("***** \(currentToken) **********")
        let wkwebView = WKWebView()

        let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                for record in records {
                    if record.displayName.contains("epicorebiosystems") {
                        dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                            print("Deleted: " + record.displayName);
                            let oneYearInSeconds = TimeInterval(60 * 60 * 24 * 365)

                            let cookie = HTTPCookie(properties: [
                                .domain: modelData.epicoreHost,
                                .path: "/mobile/insights",
                                .name: "authorization",
                                .value: "Bearer \(currentToken)",
                                .secure: true,
                                //.discard: true,
                                .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
                                .expires: NSDate(timeIntervalSinceNow: oneYearInSeconds),
                                .init(rawValue: "HttpOnly"): true
                            ])
                            let cookie1 = HTTPCookie(properties: [
                                .domain: modelData.epicoreHost,
                                .path: "/mobile/insights",
                                .name: "selectedUserRoles",
                                .value: "[{\"enterprise_id\":\"\(modelData.jwtEnterpriseID)\",\"role\":\"CH_USER\",\"site_id\":\"\(modelData.jwtSiteID)\"}]",
                                .secure: true,
                                //.discard: true,
                                .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
                                .expires: NSDate(timeIntervalSinceNow: oneYearInSeconds),
                                .init(rawValue: "HttpOnly"): true
                            ])
                            let cookie2 = HTTPCookie(properties: [
                                .domain: modelData.epicoreHost,
                                .path: "/mobile/insights",
                                .name: "language",
                                .value: languageCode,
                                .secure: true,
                                //.discard: true,
                                .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
                                .expires: NSDate(timeIntervalSinceNow: oneYearInSeconds),
                                .init(rawValue: "HttpOnly"): true
                            ])

                            if cookie != nil && cookie1 != nil && cookie2 != nil {
                                wkwebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie!) {
                                    wkwebView.reload()
                                }
                                wkwebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie1!) {
                                    wkwebView.reload()
                                }
                                wkwebView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie2!) {
                                    wkwebView.reload()
                                }
                            }
                            else {
                                logger.error("InsightsWebView - cookie creation failure")
                            }
                        })
                    }
                }
            }

        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always

        wkwebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkwebView.scrollView.isScrollEnabled = false
        wkwebView.isOpaque = false
        
        return wkwebView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.navigationDelegate = context.coordinator
        
        if(url != prevUrl || isInsightsWebViewPresented) {
            //let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            //let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            webView.load(request)
            print("webview loading url = \(url)")
            
            DispatchQueue.main.async {
                prevUrl = url
                isInsightsWebViewPresented = false
            }
        }
        
        else if (!isNetworkConnected) {
            DispatchQueue.main.async {
                prevUrl = URL(string: "https://example.com")!
                isInsightsWebViewPresented = true
            }
        }
    }
}
