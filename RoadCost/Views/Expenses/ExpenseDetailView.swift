import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    @Environment(\.dismiss) private var dismiss
    @State private var roadcostShowingFullPhoto = false
    
    private var receiptPhoto: UIImage? {
        guard let photoId = expense.receiptPhotoId else { return nil }
        return RoadCostReceiptPhotoManager.shared.roadcostLoadPhoto(id: photoId)
    }
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            AnimatedGradientMeshView()
                .opacity(0.3)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    expenseInfoCard
                    
                    if let photo = receiptPhoto {
                        receiptPhotoCard(photo: photo)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $roadcostShowingFullPhoto) {
            if let photo = receiptPhoto {
                FullPhotoView(image: photo)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text("Expense Details")
                .font(.headline)
                .foregroundStyle(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 32, height: 32)
        }
        .padding()
    }
    
    private var expenseInfoCard: some View {
        VStack(spacing: 20) {
            HStack {
                CategoryIconView(category: expense.category, size: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(expense.category.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    
                    Text(expense.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Text(expense.formattedAmount)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.accentYellow)
            }
            
            if let note = expense.note, !note.isEmpty {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Text(note)
                        .font(.body)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .glassCard()
    }
    
    private func receiptPhotoCard(photo: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Receipt Photo")
                .font(.headline)
                .foregroundStyle(.white)
            
            Button {
                roadcostShowingFullPhoto = true
            } label: {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentYellow.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .glassCard()
    }
}

struct FullPhotoView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale < 1.0 {
                                withAnimation {
                                    scale = 1.0
                                    lastScale = 1.0
                                }
                            } else if scale > 3.0 {
                                withAnimation {
                                    scale = 3.0
                                    lastScale = 3.0
                                }
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .onTapGesture(count: 2) {
            withAnimation {
                if scale > 1.0 {
                    scale = 1.0
                    lastScale = 1.0
                    offset = .zero
                    lastOffset = .zero
                } else {
                    scale = 2.0
                    lastScale = 2.0
                }
            }
        }
    }
}
