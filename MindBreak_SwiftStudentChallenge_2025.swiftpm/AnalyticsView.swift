import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("universalScore") private var score: Int = 0
    @AppStorage("universalWorkTime") private var workTime: Double = 0
    @State private var progressRecords: [DailyProgressRecord] = []
    
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
    
    init() {
        if let savedData = UserDefaults.standard.data(forKey: "progressRecords"),
           let decodedRecords = try? JSONDecoder().decode([DailyProgressRecord].self, from: savedData) {
            _progressRecords = State(initialValue: decodedRecords)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    
                    Text("Analytics for \(dateTimeFormatter.string(from: Date()))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#bcebf2"))
                        .padding(.top)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#bcebf2"))
                    }
                }
                .padding()
                
                HStack {
                    StatCard(
                        title: "Total Score",
                        value: "\(formattedScore)",
                        icon: "trophy.circle"
                    )
                    StatCard(
                        title: "Total Work Time",
                        value: formatTime(seconds: Int(workTime)),
                        icon: "timer"
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
                createScoreChart()
                
                Divider()
                
                createWorkTimeChart()
                
                Divider()
                
                createProgressStatistics()
            }
            .padding(.vertical)
        }
        .background(Color(hex: "#1f4d53"))
        .onAppear {
            addProgressRecord()
            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                addProgressRecord()
            }
        }
        .onDisappear(perform: saveRecords)
    }
    
    private func createScoreChart() -> some View {
        ChartContainer(title: "Today's Score Progress") {
            Chart(progressRecords) { record in
                LineMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Score", record.score)
                )
                .foregroundStyle(Color(hex: "#bcebf2"))
                
                AreaMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Score", record.score)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            Color(hex: "#bcebf2").opacity(0.3),
                            Color(hex: "#bcebf2").opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                PointMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Score", record.score)
                )
                .foregroundStyle(Color(hex: "#bcebf2"))
            }
            .chartXAxis {
                createTimeAxis()
            }
        }
    }
    
    private func createWorkTimeChart() -> some View {
        ChartContainer(title: "Today's Work Time Progress") {
            Chart(progressRecords) { record in
                LineMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Minutes", record.workTime / 60)
                )
                .foregroundStyle(Color(hex: "#bcebf2"))
                
                AreaMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Minutes", record.workTime / 60)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            Color(hex: "#bcebf2").opacity(0.3),
                            Color(hex: "#bcebf2").opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                PointMark(
                    x: .value("Time", record.timestamp),
                    y: .value("Minutes", record.workTime / 60)
                )
                .foregroundStyle(Color(hex: "#bcebf2"))
            }
            .chartXAxis {
                createTimeAxis()
            }
        }
    }
    
    private func createTimeAxis() -> some AxisContent {
        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
            if let date = value.as(Date.self) {
                AxisValueLabel {
                    Text(timeFormatter.string(from: date))
                        .foregroundColor(Color(hex: "#bcebf2"))
                }
            }
        }
    }
    
    private func createProgressStatistics() -> some View {
        VStack(spacing: 15) {
            if !progressRecords.isEmpty {
                MetricCard(
                    title: "Score Gained Today",
                    value: "\(formattedTodayScore)"
                )
                MetricCard(
                    title: "Work Time Added Today",
                    value: formatTime(seconds: Int(workTime - (progressRecords.first?.workTime ?? workTime)))
                )
            }
        }
        .padding(.horizontal)
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(progressRecords) {
            UserDefaults.standard.set(encoded, forKey: "progressRecords")
        }
    }
    
    private func addProgressRecord() {
        let now = Date()
        let newRecord = DailyProgressRecord(timestamp: now, score: score, workTime: workTime)
        progressRecords.append(newRecord)
        
        let calendar = Calendar.current
        progressRecords = progressRecords.filter {
            calendar.isDate($0.timestamp, inSameDayAs: now)
        }
        
        saveRecords()
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    var formattedTodayScore: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let todayScore = score - (progressRecords.first?.score ?? score)
        return formatter.string(from: NSNumber(value: todayScore)) ?? "\(todayScore)"
    }
    
    var formattedScore: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: score)) ?? "\(score)"
    }
}
