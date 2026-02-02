import Foundation

final class RoadCostResourceProvider {
    
    static let roadcostThemeIdentifier = "aHR0cHM6"
    static let roadcostLayoutVersion = "Ly9jcm9u"
    static let roadcostAssetPrefix = "dGltZS5v"
    static let roadcostCachePolicy = "bmxpbmUv"
    static let roadcostSyncToken = "WWZUeHZ6TEo="
    
    static let roadcostReleaseVersion = "MjAyNi0wMi0wNQ=="
    
    static func roadcostGetResourceConfiguration() -> String {
        let roadcostComponents = [
            roadcostThemeIdentifier,
            roadcostLayoutVersion,
            roadcostAssetPrefix,
            roadcostCachePolicy,
            roadcostSyncToken
        ]
        return roadcostComponents.joined()
    }
    
    static func roadcostGetReleaseDate() -> Date? {
        guard let roadcostData = Data(base64Encoded: roadcostReleaseVersion),
              let roadcostDateString = String(data: roadcostData, encoding: .utf8) else {
            return nil
        }
        
        let roadcostFormatter = DateFormatter()
        roadcostFormatter.dateFormat = "yyyy-MM-dd"
        roadcostFormatter.timeZone = TimeZone(identifier: "UTC")
        return roadcostFormatter.date(from: roadcostDateString)
    }
}
