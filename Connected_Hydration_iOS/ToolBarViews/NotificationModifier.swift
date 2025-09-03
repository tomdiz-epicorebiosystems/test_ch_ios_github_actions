//
//  NotificationModifier.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 8/23/23.
//

import SwiftUI

// Add unique notification Id's here
let maxDeficitIntakeNotification = "maxDeficitIntakeNotification"
let appUpdateAvailNotification = "appUpdateAvailNotification"
let bleErrorCode_11_Notification = "bleErrorCode_11_Notification"
let bleSessionRunningNotification = "bleSessionRunningNotification"

class ShowOptions {
    static let showClose = -1
    static var showNoClose = -2
}

struct NotificationModifier: ViewModifier {

    @EnvironmentObject var modelData: ModelData

    struct NotificationData {
        var id: String
        var title: String
        var detail: String
        var type: NotificationType
        var notificationLocation: NotificationLocation
        var showOnce: Bool
        var showSeconds: Int        // ShowOptions.showClose no timeout and need to close using 'X'
        var appURL: String?
    }

    enum NotificationLocation {
        case Top
        case Middle
        case Bottom
    }

    enum NotificationType {
        case Info
        case Warning
        case Success
        case Error
        
        var tintColor: Color {
            switch self {
            case .Info:
                return Color(red: 67/255, green: 154/255, blue: 215/255)
            case .Success:
                return Color.green
            case .Warning:
                return Color.yellow
            case .Error:
                return Color.red
            }
        }
    }
    
    // Members for the Notification
    @Binding var data: NotificationData
    @Binding var show: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if show && getNotificationShowOnce() == false {
                GeometryReader { proxy in
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(data.title)
                                    .bold()
                                Text(data.detail)
                                    .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))

                                if data.appURL != nil {
                                    Button(action: {
                                        guard let url = URL(string: data.appURL!) else {
                                            return
                                        }
                                        //if #available(iOS 10.0, *) {
                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                        //} else {
                                        //    UIApplication.shared.openURL(url)
                                        //}
                                    }) {
                                        Text("Update Now")
                                            .underline()
                                            .font(.custom("Roboto-Regular", size: 14))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            
                            Spacer()
                                                        
                            if data.showSeconds == ShowOptions.showClose {
                                Button(action: {
                                    withAnimation {
                                        self.show = false
                                        modelData.showNotification = false
                                        handleShowOnce()
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color.white)
                                }
                                .trackRUMTapAction(name: "notif-close")
                                .padding(.trailing, 10)
                                .font(.system(size: 24))
                            }
                        }
                        .foregroundColor(Color.white)
                        .padding(12)
                        .background(data.type.tintColor)
                        .cornerRadius(8)
                        Spacer()
                    }
                    .offset(x: 0, y: getNotificationLocation(proxy: proxy))
                }
                .padding()
                .animation(.easeInOut, value: 1.0)
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    if data.showSeconds == ShowOptions.showNoClose {
                        return
                    }
                    if data.showSeconds != ShowOptions.showClose {
                        withAnimation {
                            self.show = false
                            modelData.showNotification = false
                            handleShowOnce()
                        }
                    }
                }.onAppear(perform: {
                    if data.showSeconds != ShowOptions.showClose && data.showSeconds != ShowOptions.showNoClose {
                        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(data.showSeconds)) {
                            withAnimation {
                                self.show = false
                                modelData.showNotification = false
                                handleShowOnce()
                            }
                        }
                    }
                })
            }
        }
        .trackRUMView(name: "NotificationModifier")
    }

    func getNotificationLocation(proxy: GeometryProxy) -> CGFloat {
        if data.notificationLocation == .Top {
            return 0
        }
        else if data.notificationLocation == .Middle {
            return (proxy.size.height / 2) - 40
        }
        else {
            return proxy.size.height - 40
        }
    }
    
    func handleShowOnce() {
        if data.showOnce == true {
            UserDefaults.standard.set(true, forKey: data.id)
        }
        else {
            UserDefaults.standard.set(false, forKey: data.id)
        }
    }
    
    func getNotificationShowOnce() -> Bool {
        let showOnce = UserDefaults.standard.object(forKey: data.id)// as! Bool
        if showOnce == nil {
            UserDefaults.standard.set(false, forKey: data.id)
            return false
        }
        else {
            return showOnce as! Bool
        }
    }
}

extension View {
    func notification(data: Binding<NotificationModifier.NotificationData>, show: Binding<Bool>) -> some View {
        self.modifier(NotificationModifier(data: data, show: show))
    }
}
