import SwiftUI

struct CategoryIconView: View {
    let category: ExpenseCategory
    var size: CGFloat = 40
    
    var body: some View {
        ZStack {
            Circle()
                .fill(category.color.opacity(0.2))
                .frame(width: size, height: size)
            
            Image(systemName: category.icon)
                .font(.system(size: size * 0.5))
                .foregroundStyle(category.color)
        }
    }
}
