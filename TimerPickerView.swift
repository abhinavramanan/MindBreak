import SwiftUI

struct TimePickerView: View {
    @Environment(\.dismiss) var dismiss
    let initialTime: Int
    let onTimeSelected: (Int) -> Void
    let maxMinutes = 25
    
    @State private var minutes: Int
    @State private var seconds: Int
    
    init(initialTime: Int, onTimeSelected: @escaping (Int) -> Void) {
        self.initialTime = initialTime
        self.onTimeSelected = onTimeSelected
        _minutes = State(initialValue: initialTime / 60)
        _seconds = State(initialValue: initialTime % 60)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Set Timer")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#013640"))
            
            HStack(spacing: 16) {
                VStack {
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0...maxMinutes, id: \.self) { minute in
                            Text("\(minute)")
                                .tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    
                    Text("Minutes")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#013640"))
                }
                
                Text(":")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(Color(hex: "#013640"))
                
                VStack {
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0...59, id: \.self) { second in
                            Text(String(format: "%02d", second))
                                .tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    
                    Text("Seconds")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#013640"))
                }
            }
            .padding(.vertical)
            
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .padding()
                        .foregroundStyle(Color(hex: "#bcebf2"))
                        .background(Color(hex: "#1f4d53"))
                        .cornerRadius(20)
                }
                
                Button(action: {
                    let totalSeconds = min(minutes * 60 + seconds, maxMinutes * 60)
                    onTimeSelected(totalSeconds)
                    dismiss()
                }) {
                    Text("Set")
                        .padding()
                        .bold()
                        .background(Color(hex: "#02fcee"))
                        .foregroundColor(Color(hex: "#013640"))
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(hex: "#02a59c"))
        .presentationDetents([.height(400)])
        .presentationBackground(Color(hex: "#02a59c"))
        .onChange(of: minutes) { newValue in
            if newValue >= maxMinutes {
                minutes = maxMinutes
                seconds = 0
            }
        }
    }
}
