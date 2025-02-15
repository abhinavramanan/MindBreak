import SwiftUI
import AudioToolbox

struct TimerView: View {
    @State private var timerValue: Double = 0
    @State private var isTimerRunning = false
    @State private var startAngle: Double = 0
    @State private var timer: Timer?
    @State private var remainingTime: Double = 0
    @State private var showingGameView = false
    @State private var currentGame: CognitiveGame?
    @State private var showingGamesList = false
    @State private var showHapticFeedback = true
    @State private var showSoundEffects = true
    @State private var endTime: Date = Date()
    @State private var sessionCount: Int = 0
    @State private var showingTimePicker = false
    
    private let maxMinutes: Double = 25
    private let circleRadius: CGFloat = 150
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    private let games = [
        CognitiveGame(title: "Number Memory", description: "Remember and recall a sequence of numbers", type: .memory),
        CognitiveGame(title: "Quick Math", description: "Solve simple math problems quickly", type: .math),
        CognitiveGame(title: "Pattern Match", description: "Find matching patterns in a grid", type: .pattern),
        CognitiveGame(title: "Reaction Test", description: "Test your reaction speed", type: .reaction)
    ]
    
    var body: some View {
        VStack {     
            VStack {
                VStack {
                    HStack {
                        Label("\(sessionCount + 1)", systemImage: "tachometer")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(Color(hex: "#013640"))
                            .padding(.bottom, 5)
                        
                        Spacer()
                        if timerValue > 0 {
                            Label("\(endTimeFormatted)", systemImage: "clock")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(Color(hex: "#013640"))
                                .padding(.bottom, 5)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#39484b"), lineWidth: 20)
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                        
                        Circle()
                            .trim(from: 0, to: timerValue / (maxMinutes * 60))
                            .stroke(Color(hex: "#02fcee"), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timerValue)
                        
                        VStack {
                            Text(formatTime(seconds: Int(remainingTime)))
                                .font(.system(size: 48, weight: .medium, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(Color(hex: "#013640"))
                            
                            if !isTimerRunning {
                                withAnimation(.spring()) {
                                    Text("Slide or Tap to set time")
                                        .foregroundColor(Color(hex: "#013640"))
                                }
                            }
                        }
                        .onTapGesture {
                            if !isTimerRunning {
                                showingTimePicker = true
                                if showHapticFeedback {
                                    hapticFeedback.impactOccurred()
                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleTimerDrag(value)
                            }
                    )
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if remainingTime < maxMinutes * 60 {
                                remainingTime += 60
                                timerValue = remainingTime
                                updateEndTime()
                                if showHapticFeedback {
                                    hapticFeedback.impactOccurred()
                                }
                            }
                        }) {
                            Text("+ 1:00")
                                .padding()
                                .foregroundStyle(Color(hex: "#bcebf2"))
                                .background(Color(hex: "#1f4d53"))
                                .cornerRadius(20)
                        }
                        
                        Button(action: toggleTimer) {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: isTimerRunning ? "#e17366" : "#02fcee"))
                                .foregroundColor(Color(hex: "#013640"))
                                .cornerRadius(20)
                                .contentTransition(.symbolEffect(.replace))
                        }
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button {
                    showingGamesList.toggle()
                    if showHapticFeedback {
                        hapticFeedback.impactOccurred()
                    }
                } label: {
                    HStack {
                        Image(systemName: showingGamesList ? "arrow.down.circle" : "arrow.up.circle")
                            .font(.title2)
                            .padding(3)
                        
                        Spacer()
                        
                        Text(showingGamesList ? "Swipe down or click here to got back to the timer!" : "Swipe up or click here to break or improve cognition!")
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color(hex: "#bcebf2"))
                    .background(Color(hex: "#1f4d53"))
                    .cornerRadius(20)
                    .padding(8)

                }
            }
            .background(Color(hex: "#02a59c"))
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.height < -50 {
                            showingGamesList = true
                            if showHapticFeedback {
                                hapticFeedback.impactOccurred()
                            }
                        }
                    }
            )
            
            if showingGamesList {
                GamesListView(
                    isPresented: $showingGamesList,
                    games: games,
                    selectedGame: $currentGame,
                    showingGameView: $showingGameView
                )
                
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showingGamesList)
                .padding(.horizontal, 8)
            }
        }
        .animation(.spring())
        .sheet(isPresented: $showingGameView) {
            if let game = currentGame {
                GameView(game: game)
                    .background(Color(hex: "#02a59c"))
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(
                initialTime: Int(remainingTime),
                onTimeSelected: { newTime in
                    remainingTime = Double(newTime)
                    timerValue = remainingTime
                    updateEndTime()
                }
            )
            .background(Color(hex: "#02a59c"))
        }
    }
    
    private var endTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    private func handleTimerDrag(_ value: DragGesture.Value) {
        if !isTimerRunning {
            let center = CGPoint(x: circleRadius, y: circleRadius)
            let angle = calculateAngle(from: center, to: value.location)
            var normalizedAngle = (angle + 90).truncatingRemainder(dividingBy: 360)
            if normalizedAngle < 0 {
                normalizedAngle += 360
            }
            
            let newValue = (normalizedAngle / 360) * (maxMinutes * 60)
            timerValue = max(0, min(newValue, maxMinutes * 60))
            remainingTime = timerValue
            updateEndTime()
            
            if showHapticFeedback {
                hapticFeedback.impactOccurred(intensity: 0.5)
            }
        }
    }
    
    private func setTimer(minutes: Double) {
        guard !isTimerRunning else { return }
        remainingTime = minutes * 60
        timerValue = remainingTime
        updateEndTime()
        if showHapticFeedback {
            hapticFeedback.impactOccurred()
        }
    }
    
    private func updateEndTime() {
        endTime = Date().addingTimeInterval(remainingTime)
    }
    
    private func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
        if showHapticFeedback {
            hapticFeedback.impactOccurred()
        }
    }
    
    private func startTimer() {
        guard !isTimerRunning && remainingTime > 0 else { return }
        isTimerRunning = true
        updateEndTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
                timerValue = remainingTime
            } else {
                stopTimer()
                sessionCount += 1
                currentGame = games.randomElement()
                showingGameView = true
                if showSoundEffects {
                    AudioServicesPlaySystemSound(1007)
                }
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func calculateAngle(from center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angle = atan2(dy, dx) * (180 / .pi)
        return angle
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
