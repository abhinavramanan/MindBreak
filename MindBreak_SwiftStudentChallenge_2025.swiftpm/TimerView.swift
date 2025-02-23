import SwiftUI
import AVFoundation
#if os(macOS)
import AppKit
#endif

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
    @State private var doneTime = 0
    
    @AppStorage("universalWorkTime") private var storedWorkTime: Double = 0
    
    private let maxMinutes: Double = 25.01666666667
    private let normalCircleRadius: CGFloat = 200
    private let runningCircleRadius: CGFloat = 300
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    let games = [
        CognitiveGame(
            title: "Number Memory",
            description: """
        Challenge your short-term memory by remembering sequences of numbers that appear on screen.
        
        This game helps improve your numerical memory retention and recall abilities.
        
        How to Play:
        1. A sequence of numbers will flash on screen for a few seconds
        2. Once the numbers disappear, enter the sequence exactly as shown
        3. Each successful round adds one more digit to remember
        4. Continue until you make a mistake
        """,
            type: .memory    
        ),
        
        CognitiveGame(
            title: "Quick Math",
            description: """
        Put your mental math skills to the test by solving arithmetic problems against the clock. 
        
        This game enhances your calculation speed and numerical agility.
        
        How to Play:
        1. Simple math problems will appear on screen (addition, subtraction, multiplication)
        2. Enter your answer as quickly as possible
        3. Try to solve as many as possible within the time limit
        """,
            type: .math
        ),
        
        CognitiveGame(
            title: "Pattern Match",
            description: """
        Exercise your visual recognition skills and memory by finding matching patterns in a grid of numbers.
        
        This game improves pattern recognition and visual processing speed.
        
        How to Play:
        1. A grid of various patterns of numbers will appear and hide
        2. Find and select pairs of matching numbers
        3. Clear the entire grid by matching all pairs
        4. Complete each level within the time limit
        """,
            type: .pattern
        ),
        
        CognitiveGame(
            title: "Reaction Test",
            description: """
        Measure and improve your reaction time by responding to visual cues as fast as possible. 
        
        This game helps enhance your reflexes and hand-eye coordination.
        
        How to Play:
        1. Wait for the screen to change color
        2. Click/tap as quickly as possible when you see the change
        3. Your reaction time will be measured in milliseconds
        4. Try to beat your best time across multiple attempts
        """,
            type: .reaction
        )
    ]
    
    private var circleRadius: CGFloat {
        isTimerRunning ? runningCircleRadius : normalCircleRadius
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack {
                        Label("Work Session: \(sessionCount + 1)", systemImage: "tachometer")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(Color(hex: "#013640"))
                            .padding(.bottom, 5)
                        
                        Spacer()
                        if timerValue > 0 {
                            Label("Ends at \(endTimeFormatted)", systemImage: "clock")
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
                            .stroke(Color(hex: "#39484b"), lineWidth: isTimerRunning ? 30 : 20)
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                        
                        Circle()
                            .trim(from: 0, to: timerValue / (maxMinutes * 60))
                            .stroke(
                                Color(hex: "#02fcee"),
                                style: StrokeStyle(lineWidth: isTimerRunning ? 30 : 20, lineCap: .round)
                            )
                            .frame(width: circleRadius * 2, height: circleRadius * 2)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timerValue)
                        
                        VStack {
                            Text(formatTime(seconds: Int(remainingTime)))
                                .font(.system(size: isTimerRunning ? 100 : 70, weight: .medium, design: .rounded))
                                .bold(isTimerRunning)
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
                    .animation(.spring(duration: 1), value: isTimerRunning)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleTimerDrag(value)
                            }
                    )
                    
                    HStack(spacing: 20) {
                        Button(action: toggleTimer) {
                            Image(systemName: isTimerRunning ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: isTimerRunning ? "#e17366" : "#02fcee"))
                                .foregroundColor(Color(hex: "#013640"))
                                .cornerRadius(20)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        
                        Button(action: {
                            if isTimerRunning {
                                stopTimer()
                            }
                            
                            currentGame = games.randomElement()
                            showingGameView = true
                            if showHapticFeedback {
                                hapticFeedback.impactOccurred()
                            }
                        }) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                Text("Take Break")
                            }
                            .font(.title3)
                            .frame(width: 150, height: 50)
                            .background(Color(hex: "#02fcee"))
                            .foregroundColor(Color(hex: "#013640"))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top, isTimerRunning ? 40 : 20)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#02a59c"))
        }
        .sheet(isPresented: $showingGameView) {
            let defaultGame = CognitiveGame(
                title: "Number Memory",
                description: """
        Challenge your short-term memory by remembering sequences of numbers that appear on screen.
        
        This game helps improve your numerical memory retention and recall abilities.
        
        How to Play:
        1. A sequence of numbers will flash on screen for a few seconds
        2. Once the numbers disappear, enter the sequence exactly as shown
        3. Each successful round adds one more digit to remember
        4. Continue until you make a mistake
        """,
                type: .memory    
            )
            
            GameDetailsView(game: currentGame ?? defaultGame)
                .background(Color(hex: "#02a59c"))
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
            let location = value.location
            let angle = calculateAngle(from: center, to: location)
            var degrees = angle
            if degrees < 0 {
                degrees += 360
            }
            degrees = (degrees + 90).truncatingRemainder(dividingBy: 360)
            let percentage = degrees / 360
            let maxSeconds = maxMinutes * 60
            var newValue = percentage * Double(maxSeconds)
            
            if degrees > 359 && newValue < 1 {
                newValue = maxSeconds
            }
            
            timerValue = min(newValue, Double(maxSeconds))
            remainingTime = timerValue
            updateEndTime()
            
            if showHapticFeedback {
                hapticFeedback.impactOccurred(intensity: 0.5)
            }
        }
    }
    
    private func calculateAngle(from center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return atan2(dy, dx) * (180 / Double.pi)
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
                storedWorkTime += 1
                doneTime += 1
                timerValue = remainingTime
            } else {
                stopTimer()
                sessionCount += 1
                currentGame = games.randomElement()
                showingGameView = true
                if showSoundEffects {
                    let soundPlayer = EndingSoundPlayer()
                    soundPlayer.playSound()
                }
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

class EndingSoundPlayer: NSObject {
#if os(macOS)
    private var nsSound: NSSound?
#else
    private var audioPlayer: AVAudioPlayer?
#endif
    
    func playSound(soundFileName: String = "Finish Sound Effect", fileExtension: String = "mp3") {
#if os(macOS)
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: fileExtension) else { return }
        nsSound = NSSound(contentsOf: url, byReference: false)
        nsSound?.play()
#else
        guard let url = Bundle.main.url(forResource: soundFileName, withExtension: fileExtension) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error creating AVAudioPlayer: \(error.localizedDescription)")
        }
#endif
    }
}

