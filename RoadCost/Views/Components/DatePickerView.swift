import SwiftUI

struct DatePickerView: View {
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.leading)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.accentYellow)
                
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(Color.accentYellow)
            }
            .padding()
            .background(GlassBackground())
        }
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        DatePickerView(date: .constant(Date()))
            .padding()
    }
}
