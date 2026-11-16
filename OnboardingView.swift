import SwiftUI
import AVKit

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @Binding var showTutorial: Bool
    @State private var player: AVPlayer?
    @State private var showVideoPlayer = false
    
    private let features = [
        ("hourglass.circle.fill", "Smart Timer", "Set work sessions up to 25 minutes for better focus"),
        ("brain.head.profile", "Cognitive Games", "Quick brain exercises between sessions as breaks"),
        ("chart.line.uptrend.xyaxis", "Track Progress", "Monitor your daily focus time"),
        ("bell.badge", "Notifications", "Get notified when your session ends"),
    ]
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#02a59c")
                .ignoresSafeArea()
            
            ScrollView {
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
                    
                    Text("Studies show a global decline in cognitive abilities due to digital distractions, stress, and mental inactivity.")
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("My Student Swift Challenge 2025 submission is a productivity app that combats this by helping you maintain focus and mental freshness by combining the power of timed work intervals with engaging cognitive exercises.")
                        .font(.system(size: 24))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundStyle(Color(hex: "#013640"))
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(features, id: \.1) { icon, title, description in
                            FeatureCard(title: title, icon: icon, description: description)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            withAnimation {
                                showOnboarding = false
                            }
                        }) {
                            Label("Get Started", systemImage: "return")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#013640"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "#02fcee"))
                                .cornerRadius(15)
                        }
                        
                        Button(action: {
                            if let videoURL = Bundle.main.url(forResource: "tutorial", withExtension: "mp4") {
                                player = AVPlayer(url: videoURL)
                                showVideoPlayer = true
                            }
                        }) {
                            Label("Need more help? Watch a tutorial", systemImage: "questionmark.circle")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#013640"))
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            VideoPlayerView(player: $player)
        }
    }
}

struct FeatureCard: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(Color(hex: "#02fcee"))
                    .frame(width: 60, height: 60)
                    .background(Color(hex: "#013640"))
                    .cornerRadius(15)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#013640"))
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            
            Text(description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color(hex: "#013640"))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#bcebf2"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct VideoPlayerView: View {
    @Binding var player: AVPlayer?
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}
