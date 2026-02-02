import SwiftUI

struct AmountTextField: View {
    @Binding var text: String
    var placeholder: String = "0"
    
    var body: some View {
        HStack {
            Text("$")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            CustomTextField(
                text: $text,
                placeholder: placeholder,
                placeholderColor: UIColor(Color.accentYellow.opacity(0.6)),
                textColor: .white,
                fontSize: 34,
                fontWeight: .bold,
                keyboardType: .decimalPad,
                textAlignment: .center
            )
        }
        .padding()
        .glassCard()
    }
}
