import SwiftUI
import AudioToolbox

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1f4d53")
            VStack {
                ScoreView()
                TimerView()
                    .clipShape(
                        .rect(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
            }
        }
    }
}
