import SwiftUI

struct CategoryPickerView: View {
    @Binding var selection: ExpenseCategory
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(ExpenseCategory.allCases) { category in
                Button(action: {
                    withAnimation {
                        selection = category
                    }
                    hapticFeedback()
                }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(selection == category ? category.color : category.color.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundStyle(selection == category ? .white : category.color)
                        }
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selection == category ? 2 : 0)
                        )
                        .scaleEffect(selection == category ? 1.1 : 1.0)
                        
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}
