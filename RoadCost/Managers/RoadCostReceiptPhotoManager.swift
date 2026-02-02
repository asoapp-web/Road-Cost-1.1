import Foundation
import UIKit

final class RoadCostReceiptPhotoManager {
    
    static let shared = RoadCostReceiptPhotoManager()
    
    private let roadcostPhotosDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        roadcostPhotosDirectory = documentsPath.appendingPathComponent("ReceiptPhotos", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: roadcostPhotosDirectory.path) {
            try? FileManager.default.createDirectory(at: roadcostPhotosDirectory, withIntermediateDirectories: true)
        }
    }
    
    func roadcostSavePhoto(_ image: UIImage) -> UUID? {
        let photoId = UUID()
        let fileURL = roadcostPhotosDirectory.appendingPathComponent("\(photoId.uuidString).jpg")
        
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL)
            print("📷 [RoadCostReceiptPhotoManager] Photo saved: \(photoId)")
            return photoId
        } catch {
            print("❌ [RoadCostReceiptPhotoManager] Failed to save photo: \(error)")
            return nil
        }
    }
    
    func roadcostLoadPhoto(id: UUID) -> UIImage? {
        let fileURL = roadcostPhotosDirectory.appendingPathComponent("\(id.uuidString).jpg")
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    func roadcostDeletePhoto(id: UUID) {
        let fileURL = roadcostPhotosDirectory.appendingPathComponent("\(id.uuidString).jpg")
        try? FileManager.default.removeItem(at: fileURL)
        print("📷 [RoadCostReceiptPhotoManager] Photo deleted: \(id)")
    }
    
    func roadcostDeleteAllPhotos() {
        let contents = (try? FileManager.default.contentsOfDirectory(at: roadcostPhotosDirectory, includingPropertiesForKeys: nil)) ?? []
        for file in contents {
            try? FileManager.default.removeItem(at: file)
        }
        print("📷 [RoadCostReceiptPhotoManager] All photos deleted")
    }
}
