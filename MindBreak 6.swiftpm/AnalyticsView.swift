import SwiftUI
import Charts

// Structure to store score records with timestamp
struct ScoreRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let score: Int
    
    init(timestamp: Date, score: Int) {
        self.id = UUID()
        self.timestamp = timestamp
        self.score = score
    }
}

struct ChartContainer<Content: View>: View {
    let title: String
    let content: () -> Content  // Changed to closure type
    
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#bcebf2"))
                .padding(.horizontal)
            
            content()  // Call the closure here
                .frame(height: 200)
                .padding()
        }
        .background(Color(hex: "#1f4d53").opacity(0.6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}


struct DailyProgressRecord: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let score: Int
    let workTime: Double
    
    init(timestamp: Date, score: Int, workTime: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.score = score
        self.workTime = workTime
    }
}

struct AnalyticsView: View {
    @AppStorage("universalScore") private var score: Int = 0
    @AppStorage("universalWorkTime") private var workTime: Double = 0
    
    @State private var progressRecords: [DailyProgressRecord] = []
    
    // Date formatters
    private let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
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
        // Load saved records
        if let savedData = UserDefaults.standard.data(forKey: "progressRecords"),
           let decodedRecords = try? JSONDecoder().decode([DailyProgressRecord].self, from: savedData) {
            _progressRecords = State(initialValue: decodedRecords)
        }
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(progressRecords) {
            UserDefaults.standard.set(encoded, forKey: "progressRecords")
        }
    }
    
    private func addProgressRecord() {
        let now = Date()
        let newRecord = DailyProgressRecord(timestamp: now, score: score, workTime: workTime)
        
        // Add new record
        progressRecords.append(newRecord)
        
        // Keep only today's records
        let calendar = Calendar.current
        progressRecords = progressRecords.filter {
            calendar.isDate($0.timestamp, inSameDayAs: now)
        }
        
        saveRecords()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current Date and Time Display (UTC)
                Text(dateTimeFormatter.string(from: Date()))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#bcebf2"))
                    .padding(.top)
                
                // Current Stats
                HStack {
                    StatCard(
                        title: "Total Score",
                        value: "\(score)",
                        icon: "trophy.circle"
                    )
                    
                    StatCard(
                        title: "Total Work Time",
                        value: formatTime(seconds: Int(workTime)),
                        icon: "timer"
                    )
                }
                .padding(.horizontal)
                
                // Today's Score Progress Chart
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
                        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(timeFormatter.string(from: date))
                                        .foregroundColor(Color(hex: "#bcebf2"))
                                }
                            }
                        }
                    }
                }
                
                // Today's Work Time Progress Chart
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
                        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                            if let date = value.as(Date.self) {
                                AxisValueLabel {
                                    Text(timeFormatter.string(from: date))
                                        .foregroundColor(Color(hex: "#bcebf2"))
                                }
                            }
                        }
                    }
                }
                
                // Today's Progress Statistics
                VStack(spacing: 15) {
                    if !progressRecords.isEmpty {
                        MetricCard(
                            title: "Points Gained Today",
                            value: "\(score - (progressRecords.first?.score ?? score))"
                        )
                        
                        MetricCard(
                            title: "Time Added Today",
                            value: formatTime(seconds: Int(workTime - (progressRecords.first?.workTime ?? workTime)))
                        )
                        
                        MetricCard(
                            title: "Productivity Rate",
                            value: String(format: "%.2f pts/min", calculateProductivityRate())
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(hex: "#1f4d53"))
        .onAppear {
            addProgressRecord()
            // Set up a timer to update records every 5 minutes
            Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
                addProgressRecord()
            }
        }
        .onDisappear(perform: saveRecords)
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func calculateProductivityRate() -> Double {
        guard !progressRecords.isEmpty else { return 0 }
        let totalScore = Double(score - (progressRecords.first?.score ?? score))
        let totalTime = (workTime - (progressRecords.first?.workTime ?? workTime)) / 60 // Convert to minutes
        return totalTime > 0 ? totalScore / totalTime : 0
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(hex: "#1f4d53").opacity(0.6))
        .foregroundColor(Color(hex: "#bcebf2"))
        .cornerRadius(15)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(hex: "#1f4d53").opacity(0.6))
        .foregroundColor(Color(hex: "#bcebf2"))
        .cornerRadius(15)
    }
}

