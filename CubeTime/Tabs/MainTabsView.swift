import SwiftUI
import CoreData

enum Tab {
    case timer
    case solves
    case stats
    case sessions
    case settings
}

class TabRouter: ObservableObject {
    static let shared = TabRouter()
    
    @Published var currentTab: Tab = .timer {
        didSet {
            if currentTab == .timer {
                padExpandState = 0
            }
        }
    }
    @Published var hideTabBar: Bool = false
    @Published var padExpandState: Int = 0 {
        didSet {
            if padExpandState == 1 && currentTab == .timer {
                currentTab = .solves
            }
        }
    }
}


struct MainTabsView: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @EnvironmentObject var tabRouter: TabRouter
    
    var body: some View {
        VStack {
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    TimerView()
                        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                case .solves:
                    TimeListView()
                case .stats:
                    StatsView()
                case .sessions:
                    SessionsView()
                case .settings:
                    SettingsView()
                }
                
                
                if !tabRouter.hideTabBar {
                    TabBar(currentTab: $tabRouter.currentTab)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, UIDevice.hasBottomBar ? CGFloat(0) : nil)
                        .padding(.bottom, UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) ? nil : 0)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}
