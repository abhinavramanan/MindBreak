import SwiftUI

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
