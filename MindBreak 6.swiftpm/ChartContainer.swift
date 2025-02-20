import SwiftUI

struct ChartContainer<Content: View>: View {
    let title: String
    let content: () -> Content
    
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
            
            content()
                .frame(height: 200)
                .padding()
        }
        .background(Color(hex: "#1f4d53").opacity(0.6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
