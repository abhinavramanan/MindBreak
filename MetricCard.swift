import SwiftUI

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
