import SwiftUI

struct ScoreView: View {
    @AppStorage("universalScore") private var score: Int = 0
    @AppStorage("universalWorkTime") private var workTime: Double = 0
    @State private var showAnalytics = false
    
    var body: some View {
        ZStack {
            HStack {
                Label("Total Elapsed Time: \(formatTime(seconds: Int(workTime)))", systemImage: "timer")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                
                Spacer()
                
                Label("Total Score: \(score)", systemImage: "trophy.circle")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
            }
            .padding()
            .foregroundStyle(Color(hex: "#bcebf2"))
            .background(Color(hex: "#1f4d53"))
            
            Button(action: {
                showAnalytics = true
            }) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("View Analytics")
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#1f4d53"))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(hex: "#bcebf2"))
                .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsView()
        }
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
