import SwiftUI
import Photos
import AVFoundation

struct AddExpenseView: View {
    @StateObject var viewModel: AddExpenseViewModel
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    @State private var roadcostShowingPhotoSourceDialog = false
    @State private var roadcostShowingImagePicker = false
    @State private var roadcostImagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var roadcostSelectedImage: UIImage?
    
    init(viewModel: AddExpenseViewModel, isPresented: Binding<Bool>, onSave: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isPresented = isPresented
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            Color.backgroundDark.ignoresSafeArea()
            OrbitalCirclesView()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                    Text("New Expense")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: {
                        viewModel.saveExpense()
                        onSave()
                        isPresented = false
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(viewModel.isValid ? Color.accentYellow : .white.opacity(0.3))
                    }
                    .disabled(!viewModel.isValid)
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount
                        VStack(alignment: .leading) {
                            Text("Amount")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            AmountTextField(text: $viewModel.amount)
                        }
                        
                        // Category
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            CategoryPickerView(selection: $viewModel.selectedCategory)
                                .padding()
                                .glassCard()
                        }
                        
                        // Date
                        DatePickerView(date: $viewModel.selectedDate)
                        
                        // Note
                        VStack(alignment: .leading) {
                            Text("Note")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundStyle(Color.accentYellow)
                                
                                CustomTextField(
                                    text: $viewModel.note,
                                    placeholder: "Expense description",
                                    placeholderColor: UIColor(Color.accentYellow.opacity(0.6)),
                                    textColor: .white,
                                    fontSize: 17,
                                    fontWeight: .regular,
                                    keyboardType: .default,
                                    textAlignment: .left
                                )
                            }
                            .padding()
                            .glassCard()
                        }
                        
                        // Receipt Photo
                        VStack(alignment: .leading) {
                            Text("Receipt Photo")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                                .padding(.leading)
                            
                            if let photo = viewModel.receiptPhoto {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    
                                    Button {
                                        viewModel.removeReceiptPhoto()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                            .background(Circle().fill(Color.black.opacity(0.5)))
                                    }
                                    .padding(8)
                                }
                                .glassCard()
                            } else {
                                Button {
                                    roadcostShowingPhotoSourceDialog = true
                                } label: {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                            .foregroundStyle(Color.accentYellow)
                                        Text("Add Receipt Photo")
                                            .foregroundStyle(.white.opacity(0.6))
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundStyle(Color.accentYellow.opacity(0.6))
                                    }
                                    .padding()
                                    .glassCard()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onChange(of: viewModel.amount) { _, _ in
            viewModel.validateForm()
        }
        .confirmationDialog("Choose Photo Source", isPresented: $roadcostShowingPhotoSourceDialog, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Camera") {
                    roadcostRequestCameraPermission()
                }
            }
            Button("Photo Library") {
                roadcostRequestPhotoLibraryPermission()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $roadcostShowingImagePicker) {
            RoadCostImagePicker(roadcostSelectedImage: $roadcostSelectedImage, roadcostSourceType: roadcostImagePickerSource)
        }
        .onChange(of: roadcostSelectedImage) { _, newValue in
            if let image = newValue {
                viewModel.receiptPhoto = image
                roadcostSelectedImage = nil
            }
        }
    }
    
    private func roadcostRequestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    roadcostImagePickerSource = .camera
                    roadcostShowingImagePicker = true
                }
            }
        }
    }
    
    private func roadcostRequestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                if status == .authorized || status == .limited {
                    roadcostImagePickerSource = .photoLibrary
                    roadcostShowingImagePicker = true
                }
            }
        }
    }
}
