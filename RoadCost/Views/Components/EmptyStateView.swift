import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.accentYellow.opacity(0.6))
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentYellow)
                    .cornerRadius(24)
                    .foregroundStyle(.white)
                }
                .padding(.top, 8)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()
        EmptyStateView(
            icon: "tray",
            title: "No Expenses Yet",
            message: "Start tracking your expenses by adding your first entry",
            actionTitle: "Add Expense"
        ) {
            print("Add tapped")
        }
    }
}
