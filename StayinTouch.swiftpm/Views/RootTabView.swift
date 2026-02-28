import SwiftUI

/// Main tab navigation: Home | Today | Settings
/// Uses iOS 26's native TabView which automatically adopts Liquid Glass for the tab bar.
struct RootTabView: View {
    @Bindable var viewModel: AppViewModel
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home
        case people
        case settings
        
        var title: String {
            switch self {
            case .home:     "Home"
            case .people:   "People"
            case .settings: "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .home:     "house.fill"
            case .people:   "person.2.fill"
            case .settings: "gearshape.fill"
            }
        }
    }
    
    // Incremented every time the Home tab is tapped while already selected.
    // HomeTabView observes this to deselect the current contact.
    @State private var homeTabRetapID: Int = 0

    var body: some View {
        TabView(
            selection: Binding(
                get: { selectedTab },
                set: { newTab in
                    if newTab == .home && selectedTab == .home {
                        homeTabRetapID += 1
                    }
                    selectedTab = newTab
                }
            )
        ) {
            HomeTabView(viewModel: viewModel, homeRetapID: homeTabRetapID)
                .tabItem {
                    Label(Tab.home.title, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)

            PeopleTabView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.people.title, systemImage: Tab.people.icon)
                }
                .tag(Tab.people)

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label(Tab.settings.title, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.stAccent)
        .preferredColorScheme(.dark)
    }
}
