//
//  IntakeTabView.swift
//  Connected_Hydration_iOS
//
//  Created by Thomas DiZoglio on 3/9/23.
//

import SwiftUI
import SwiftUITrackableScrollView

struct IntakeTabView: View {
    
    @EnvironmentObject var modelData: ModelData
    @Environment(\.navigate) private var navigate

    @State private var navigationPath: [MainOnboardingRoute] = []
    @State private var scrollViewContentOffset = CGFloat(0)

    @Binding var tabSelection: Tab

    @State private var hideFractionalMenu = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                BgStatusView() {}
                    .clipped()
                TrackableScrollView(.vertical, showIndicators: true, contentOffset: $scrollViewContentOffset) {
                    IntakeView(tabSelection: $tabSelection, hideFractionalMenu: $hideFractionalMenu)
                        .id(modelData.rootViewId)
                        .frame(maxWidth: .infinity)
                        .background(RoundedCorners(color: .white, tl: 30, tr: 30, bl: 0, br: 0))
                        .offset(y: 50)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        .transition(.move(edge: .bottom))
                        .navigationDestination(for: MainOnboardingRoute.self) { screen in
                            switch screen {
                            case .intakeAddBottle:
                                AddBottleView(tabSelection: $tabSelection)
                            case .intakeEnterManually:
                                EnterItemManually(tabSelection: $tabSelection).environmentObject(modelData)
                            case .intakeBottleList:
                                BottleListView(tabSelection: $tabSelection).navigationBarBackButtonHidden(true)
                            default:
                                EmptyView()
                            }
                        }
                }
                .clipped()
                .onChange(of: scrollViewContentOffset, perform: { value in
                    self.hideFractionalMenu = true
                })
                
                BgTabIntakeExtensionView(tabSelection: $tabSelection)
                    .clipped()
            }
            .addToolbar()
            .trackRUMView(name: "IntakeTabView")
        }
        .navigationBarTitleDisplayMode(.inline)
        .onNavigate { navType in
            switch navType {
            case .push(let route):
                navigationPath.append(route)
            case .unwind(let route):
                if route == .intakeAddBottle {
                    navigationPath = []
                } else {
                    guard let index = navigationPath.firstIndex(where: { $0 == route })  else { return }
                    navigationPath = Array(navigationPath.prefix(upTo: index + 1))
                }
            }
        }
    }
}
