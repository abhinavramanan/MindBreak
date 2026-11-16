import SwiftUI
import AudioToolbox

struct ContentView: View {
    @State private var showOnboarding = true
    @State private var showTutorial = false
    
    var body: some View {
        ZStack {
            Color(hex: "#1f4d53")
                .ignoresSafeArea()
            VStack {
                ScoreView()
                TimerView()
                    .clipShape(.rect(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    ))
            }
            
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding, showTutorial: $showTutorial)
            }
        }
    }
}
