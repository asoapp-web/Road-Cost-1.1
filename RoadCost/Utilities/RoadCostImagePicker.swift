import SwiftUI
import UIKit

struct RoadCostImagePicker: UIViewControllerRepresentable {
    @Binding var roadcostSelectedImage: UIImage?
    var roadcostSourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) var roadcostDismiss
    
    func makeCoordinator() -> RoadCostImagePickerCoordinator {
        RoadCostImagePickerCoordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let roadcostPicker = UIImagePickerController()
        roadcostPicker.sourceType = roadcostSourceType
        roadcostPicker.delegate = context.coordinator
        roadcostPicker.allowsEditing = true
        return roadcostPicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

class RoadCostImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let roadcostParent: RoadCostImagePicker
    
    init(_ parent: RoadCostImagePicker) {
        self.roadcostParent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let roadcostEditedImage = info[.editedImage] as? UIImage {
            roadcostParent.roadcostSelectedImage = roadcostEditedImage
        } else if let roadcostOriginalImage = info[.originalImage] as? UIImage {
            roadcostParent.roadcostSelectedImage = roadcostOriginalImage
        }
        roadcostParent.roadcostDismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        roadcostParent.roadcostDismiss()
    }
}
