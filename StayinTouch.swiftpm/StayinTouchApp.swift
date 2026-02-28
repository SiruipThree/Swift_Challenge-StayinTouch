import SwiftUI

@main
struct StayinTouchApp: App {
    @State private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.hasCompletedOnboarding {
                    RootTabView(viewModel: viewModel)
                        .transition(.opacity)
                } else {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            viewModel.hasCompletedOnboarding = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.hasCompletedOnboarding)
        }
    }
}
