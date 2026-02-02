import SwiftUI

struct GlassCardView<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let padding: CGFloat
    
    init(content: Content, cornerRadius: CGFloat = 16, padding: CGFloat = 16) {
        self.content = content
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                GlassBackground(cornerRadius: cornerRadius)
            )
    }
}
