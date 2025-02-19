import SwiftUI

// Tutorial step model to track progress
struct TutorialStep: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let highlightFrame: CGRect?
    let alignment: Alignment
}

// Tutorial overlay view
struct TutorialView: View {
    @Binding var isShowingTutorial: Bool
    @State private var currentStepIndex = 0
    
    let steps = [
        TutorialStep(
            title: "Set Your Time",
            message: "Drag around the circle or tap to set your work session duration",
            highlightFrame: nil,
            alignment: .center
        ),
        TutorialStep(
            title: "Start Session",
            message: "Tap the play button to begin your focused work session",
            highlightFrame: nil,
            alignment: .bottom
        ),
        TutorialStep(
            title: "Take Breaks",
            message: "Complete quick brain games during breaks to stay sharp",
            highlightFrame: nil,
            alignment: .center
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.75)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Text(steps[currentStepIndex].title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#02fcee"))
                    
                    Text(steps[currentStepIndex].message)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        if currentStepIndex > 0 {
                            Button("Previous") {
                                currentStepIndex -= 1
                            }
                            .buttonStyle(TutorialButtonStyle())
                        }
                        
                        Button(currentStepIndex == steps.count - 1 ? "Finish" : "Next") {
                            if currentStepIndex < steps.count - 1 {
                                currentStepIndex += 1
                            } else {
                                isShowingTutorial = false
                            }
                        }
                        .buttonStyle(TutorialButtonStyle())
                    }
                    .padding(.top)
                }
                .padding()
                .background(Color(hex: "#013640"))
                .cornerRadius(15)
                .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TutorialButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: "#013640"))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color(hex: "#02fcee"))
            .cornerRadius(10)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @Binding var showTutorial: Bool
    
    private let features = [
        ("hourglass.circle.fill", "Smart Timer", "Set your work sessions up to 25 minutes"),
        ("brain.head.profile", "Cognitive Games", "Quick brain exercises between sessions as breaks"),
        ("chart.line.uptrend.xyaxis", "Track Progress", "Monitor your daily focus time"),
        ("bell.badge", "Notifications", "Get notified when your session ends"),
        ("accessibility", "Accessibility", "Compatible with Apple accessibility")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack {
                    Text("MindBreak")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .padding(.top, 40)
                    
                    Text("Boost your productivity with timed work sessions and brain games")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color(hex: "#bcebf2"))
                .background(Color(hex: "#1f4d53"))
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 0
                    )
                )
                
                VStack(spacing: 25) {
                    ForEach(features, id: \.1) { icon, title, description in
                        HStack(spacing: 15) {
                            Image(systemName: icon)
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "#02fcee"))
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "#013640"))
                                .cornerRadius(15)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                                
                                Text(description)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(hex: "#013640"))
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            showOnboarding = false
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#013640"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#02fcee"))
                            .cornerRadius(15)
                    }
                    
                    Button(action: {
                        showOnboarding = false
                        showTutorial = true
                    }) {
                        Text("Need more help? Watch a tutorial")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "#02fcee"))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}
