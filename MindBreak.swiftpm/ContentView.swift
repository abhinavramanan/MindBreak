import SwiftUI
import AudioToolbox

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "#02a59c")
            VStack {
                ScoreView()
                TimerView()
            }
        }
    }
}
