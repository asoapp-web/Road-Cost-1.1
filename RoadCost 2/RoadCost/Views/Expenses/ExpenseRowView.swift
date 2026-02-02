import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 16) {
            CategoryIconView(category: expense.category, size: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(expense.category.displayName)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    if expense.hasReceiptPhoto {
                        Image(systemName: "camera.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.accentYellow.opacity(0.8))
                    }
                }
                
                HStack(spacing: 8) {
                    Text(expense.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    if let note = expense.note {
                        Text("• \(note)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            Text(expense.formattedAmount)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.accentYellow)
        }
        .padding()
        .glassCard()
    }
}
