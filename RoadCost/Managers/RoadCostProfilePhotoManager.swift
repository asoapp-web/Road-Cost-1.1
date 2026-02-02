import Foundation
import UIKit
import Combine

final class RoadCostProfilePhotoManager: ObservableObject {
    
    static let shared = RoadCostProfilePhotoManager()
    
    @Published var roadcostProfilePhoto: UIImage?
    
    private let roadcostPhotoKey = "roadcost_profile_photo_v1"
    
    private init() {
        roadcostLoadPhoto()
    }
    
    func roadcostSavePhoto(_ image: UIImage) {
        if let roadcostData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(roadcostData, forKey: roadcostPhotoKey)
            roadcostProfilePhoto = image
            print("📷 [RoadCostProfilePhotoManager] Photo saved")
        }
    }
    
    func roadcostLoadPhoto() {
        if let roadcostData = UserDefaults.standard.data(forKey: roadcostPhotoKey),
           let roadcostImage = UIImage(data: roadcostData) {
            roadcostProfilePhoto = roadcostImage
            print("📷 [RoadCostProfilePhotoManager] Photo loaded")
        }
    }
    
    func roadcostDeletePhoto() {
        UserDefaults.standard.removeObject(forKey: roadcostPhotoKey)
        roadcostProfilePhoto = nil
        print("📷 [RoadCostProfilePhotoManager] Photo deleted")
    }
}
