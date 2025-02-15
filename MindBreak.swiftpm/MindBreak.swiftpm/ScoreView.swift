import SwiftUI

struct ScoreView: View {
    @AppStorage("universalScore") private var score: Int = 0
    @AppStorage("universalWorkTime") private var workTime: Double = 0
    
    var body: some View {
        HStack {
            Label("\(formatTime(seconds: Int(workTime)))", systemImage: "timer")
                .font(.system(size: 20, weight: .medium, design: .rounded))
            
            Spacer()
            
            Label("\(score)", systemImage: "trophy.circle")
                .font(.system(size: 20, weight: .medium, design: .rounded))
        }
        .padding()
        .foregroundStyle(Color(hex: "#bcebf2"))
        .background(Color(hex: "#1f4d53"))
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
