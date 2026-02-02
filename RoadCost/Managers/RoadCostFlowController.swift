import Foundation
import UIKit
import StoreKit
import Combine

enum RoadCostDisplayState {
    case preparing
    case original
    case webContent
}

final class RoadCostFlowController: ObservableObject {
    
    static let shared = RoadCostFlowController()
    
    @Published var roadcostDisplayMode: RoadCostDisplayState = .preparing
    @Published var roadcostTargetEndpoint: String?
    @Published var roadcostIsLoading: Bool = true
    
    private let roadcostFallbackStateKey = "roadcost_persistent_state_v1"
    private let roadcostWebViewShownKey = "roadcost_webview_shown_v1"
    private let roadcostRatingShownKey = "roadcost_rating_shown_v1"
    
    private init() {
        roadcostInitializeFlow()
    }
    
    private func roadcostInitializeFlow() {
        print("🔄 [RoadCostFlowController] Initializing...")
        
        if roadcostIsTabletDevice() {
            print("⚪ [RoadCostFlowController] iPad detected - secondary mode")
            roadcostActivateSecondaryMode()
            return
        }
        
        if roadcostGetFallbackState() {
            print("⚪ [RoadCostFlowController] Persistent fallback state - secondary mode")
            roadcostActivateSecondaryMode()
            return
        }
        
        if !roadcostCheckTemporalCondition() {
            print("⚪ [RoadCostFlowController] Activation date not reached - secondary mode")
            roadcostActivateSecondaryMode()
            return
        }
        
        if let roadcostEndpoint = RoadCostDataProcessor.roadcostGetProcessedResource() {
            print("🌐 [RoadCostFlowController] Resource obtained - primary mode")
            roadcostTargetEndpoint = roadcostEndpoint
            roadcostActivatePrimaryMode()
        } else {
            print("⚪ [RoadCostFlowController] Failed to get resource - secondary mode")
            roadcostActivateSecondaryMode()
        }
    }
    
    private func roadcostIsTabletDevice() -> Bool {
        let roadcostIsPhysicallyPad = UIDevice.current.model.contains("iPad")
        let roadcostIsInterfacePad = UIDevice.current.userInterfaceIdiom == .pad
        return roadcostIsPhysicallyPad || roadcostIsInterfacePad
    }
    
    private func roadcostCheckTemporalCondition() -> Bool {
        guard let roadcostActivationDate = RoadCostResourceProvider.roadcostGetReleaseDate() else {
            return false
        }
        return Date() >= roadcostActivationDate
    }
    
    private func roadcostGetFallbackState() -> Bool {
        return UserDefaults.standard.bool(forKey: roadcostFallbackStateKey)
    }
    
    private func roadcostSetFallbackState(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: roadcostFallbackStateKey)
    }
    
    func roadcostActivateSecondaryMode() {
        DispatchQueue.main.async { [weak self] in
            self?.roadcostDisplayMode = .original
            self?.roadcostIsLoading = false
            self?.roadcostSetFallbackState(true)
            print("⚪ [RoadCostFlowController] Secondary mode activated")
        }
    }
    
    func roadcostActivatePrimaryMode() {
        DispatchQueue.main.async { [weak self] in
            self?.roadcostDisplayMode = .webContent
            self?.roadcostIsLoading = false
            UserDefaults.standard.set(true, forKey: self?.roadcostWebViewShownKey ?? "")
            print("🌐 [RoadCostFlowController] Primary mode activated")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.roadcostShowRatingIfNeeded()
            }
        }
    }
    
    private func roadcostShowRatingIfNeeded() {
        let roadcostAlreadyShown = UserDefaults.standard.bool(forKey: roadcostRatingShownKey)
        guard !roadcostAlreadyShown else { return }
        
        if let roadcostScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: roadcostScene)
            UserDefaults.standard.set(true, forKey: roadcostRatingShownKey)
            print("⭐ [RoadCostFlowController] Rating prompt shown")
        }
    }
}
