//
//  WebView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 5/10/23.
//

import SwiftUI
import WebKit
 
var hideBackground = false

struct WebView: UIViewRepresentable {
    var url: URL
    let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // This injection stops users from selecting text in webview
            let javascriptStyle = "var css = '*{-webkit-touch-callout:none;-webkit-user-select:none}'; var head = document.head || document.getElementsByTagName('head')[0]; var style = document.createElement('style'); style.type = 'text/css'; style.appendChild(document.createTextNode(css)); head.appendChild(style);"
            webView.evaluateJavaScript(javascriptStyle, completionHandler: nil)

            // Used to hide PDF file page counts
            guard let last = webView.subviews.last else {
                return
            }

            last.isHidden = hideBackground
        }
    }

    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let wkwebView = WKWebView()
        // Turns off PDF page count. Only needed for Japanese PDF files - HTML loads will not work
        if (languageCode == "ja") {
            let urlLoad = url.absoluteString
            if (urlLoad.contains(".pdf")) {
                hideBackground = true
            }
            else {
                hideBackground = false
            }
        }
        else {
            hideBackground = false
        }
        wkwebView.navigationDelegate = context.coordinator
        wkwebView.underPageBackgroundColor = .white
        wkwebView.backgroundColor = .clear
        wkwebView.isOpaque = false
        return wkwebView
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadFileURL(url, allowingReadAccessTo: url)
        //let request = URLRequest(url: url)
        //webView.load(request)
    }
}
