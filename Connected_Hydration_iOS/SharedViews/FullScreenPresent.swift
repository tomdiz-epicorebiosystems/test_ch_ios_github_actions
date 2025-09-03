//
//  FullScreenPresent.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 4/6/23.
//

import SwiftUI
import UIKit

extension View {
    /// This is used for presenting any SwiftUI view in UIKit way. As it uses some tricky way to make the objective, could possibly happen some issues at every upgrade of iOS version.
    /// iOS 14 provides `.fullScreenCover` to support full screen presenting, it, however, seems not to work well if the SwiftUI view that has this modifier is contained in any UIKit view.
    ///  - After dismissal of a content view, all subviews of the content view will be reconstructed.
    func uiKitFullPresent<V: View>(isPresented: Binding<Bool>, animated: Bool = true, transitionStyle: UIModalTransitionStyle = .coverVertical, presentStyle: UIModalPresentationStyle = .fullScreen, content: @escaping (_ dismissHandler: @escaping (_ completion: @escaping () -> Void) -> Void) -> V) -> some View {
        self.modifier(FullScreenPresent(isPresented: isPresented, animated: animated, transitionStyle: transitionStyle, presentStyle: presentStyle, contentView: content))
    }
    
    func uiKitFullPresent<V: View>(isPresented: Binding<Bool>, animated: Bool = true, customTransitionDelegate: UIViewControllerTransitioningDelegate, content: @escaping (_ dismissHandler: @escaping (_ completion: @escaping () -> Void) -> Void) -> V) -> some View {
        self.modifier(FullScreenPresent(isPresented: isPresented, animated: animated, transitioningDelegate: customTransitionDelegate, contentView: content))
    }
}

struct FullScreenPresent<V: View>: ViewModifier {
    typealias ContentViewBlock = (_ dismissHandler: @escaping (_ completion: @escaping () -> Void) -> Void) -> V
    
    @Binding var isPresented: Bool
    @State private var isAlreadyPresented: Bool = false

    let animated: Bool
    var transitionStyle: UIModalTransitionStyle = .coverVertical
    var presentStyle: UIModalPresentationStyle = .fullScreen
    let contentView: ContentViewBlock
    
    private var transitioningDelegate: UIViewControllerTransitioningDelegate? = nil
    
    init(isPresented: Binding<Bool>, animated: Bool, transitionStyle: UIModalTransitionStyle, presentStyle: UIModalPresentationStyle, contentView: @escaping ContentViewBlock) {
        self._isPresented = isPresented
        self.animated = animated
        self.transitionStyle = transitionStyle
        self.presentStyle = presentStyle
        self.contentView = contentView
    }
    
    init(isPresented: Binding<Bool>, animated: Bool, transitioningDelegate: UIViewControllerTransitioningDelegate, contentView: @escaping ContentViewBlock) {
        self._isPresented = isPresented
        self.animated = animated
        self.transitioningDelegate = transitioningDelegate
        self.contentView = contentView
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        contentFullView(content)
    }

    // Changed implementation
    func contentFullView(_ content: Content) -> some View {
        content
            .onChange(of: isPresented) { _ in
                if isPresented {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        let topMost = UIViewController.topMost
                        let rootView = contentView({ [weak topMost] completion in
                            topMost?.dismiss(animated: animated) {
                                completion()
                                isPresented = false
                            }
                        })
                        let hostingVC = UIHostingController(rootView: rootView)
                        
                        if let customTransitioning = transitioningDelegate {
                            hostingVC.modalPresentationStyle = .custom
                            hostingVC.transitioningDelegate = customTransitioning
                        } else {
                            hostingVC.modalPresentationStyle = presentStyle
                            if presentStyle == .overFullScreen {
                                hostingVC.view.backgroundColor = .clear
                            }
                            hostingVC.modalTransitionStyle = transitionStyle
                        }
                        
                        topMost?.present(hostingVC, animated: animated, completion: nil)
                    }
                }
            }
    }
}

extension UIViewController {
    static var topMost: UIViewController? {
        let keyWindow = UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }
        //let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
