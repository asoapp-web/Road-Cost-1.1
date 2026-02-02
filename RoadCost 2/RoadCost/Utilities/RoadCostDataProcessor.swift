import Foundation

final class RoadCostDataProcessor {
    
    static func roadcostProcessResourceData(_ input: String) -> String? {
        guard let roadcostData = Data(base64Encoded: input) else {
            return nil
        }
        return String(data: roadcostData, encoding: .utf8)
    }
    
    static func roadcostGetProcessedResource() -> String? {
        let roadcostRawData = RoadCostResourceProvider.roadcostGetResourceConfiguration()
        return roadcostProcessResourceData(roadcostRawData)
    }
}
