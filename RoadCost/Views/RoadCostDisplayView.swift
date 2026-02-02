import SwiftUI
import WebKit

struct RoadCostDisplayView: View {
    @ObservedObject var roadcostFlowController = RoadCostFlowController.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let roadcostEndpoint = roadcostFlowController.roadcostTargetEndpoint,
               let roadcostURL = URL(string: roadcostEndpoint) {
                RoadCostWebView(roadcostURL: roadcostURL)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

struct RoadCostWebView: UIViewRepresentable {
    let roadcostURL: URL
    
    func makeCoordinator() -> RoadCostWebCoordinator {
        RoadCostWebCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let roadcostConfiguration = WKWebViewConfiguration()
        roadcostConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        roadcostConfiguration.allowsInlineMediaPlayback = true
        roadcostConfiguration.mediaTypesRequiringUserActionForPlayback = []
        roadcostConfiguration.allowsAirPlayForMediaPlayback = true
        roadcostConfiguration.allowsPictureInPictureMediaPlayback = true
        roadcostConfiguration.websiteDataStore = WKWebsiteDataStore.default()
        
        let roadcostWebView = WKWebView(frame: .zero, configuration: roadcostConfiguration)
        roadcostWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        roadcostWebView.allowsBackForwardNavigationGestures = true
        roadcostWebView.scrollView.keyboardDismissMode = .interactive
        roadcostWebView.allowsLinkPreview = false
        roadcostWebView.navigationDelegate = context.coordinator
        roadcostWebView.uiDelegate = context.coordinator
        
        let roadcostRefreshControl = UIRefreshControl()
        roadcostRefreshControl.addTarget(context.coordinator, action: #selector(RoadCostWebCoordinator.roadcostHandleRefresh(_:)), for: .valueChanged)
        roadcostWebView.scrollView.refreshControl = roadcostRefreshControl
        
        context.coordinator.roadcostWebView = roadcostWebView
        
        roadcostLoadCookies(into: roadcostWebView) {
            roadcostWebView.load(URLRequest(url: self.roadcostURL))
        }
        
        return roadcostWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func roadcostLoadCookies(into webView: WKWebView, completion: @escaping () -> Void) {
        guard let roadcostCookiesData = UserDefaults.standard.data(forKey: "roadcost_saved_cookies_v1"),
              let roadcostCookiesArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(roadcostCookiesData) as? [[String: Any]] else {
            completion()
            return
        }
        
        let roadcostGroup = DispatchGroup()
        for roadcostCookieDict in roadcostCookiesArray {
            if let roadcostCookie = HTTPCookie(properties: roadcostCookieDict as! [HTTPCookiePropertyKey: Any]) {
                roadcostGroup.enter()
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(roadcostCookie) {
                    roadcostGroup.leave()
                }
            }
        }
        roadcostGroup.notify(queue: .main, execute: completion)
    }
}

class RoadCostWebCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    weak var roadcostWebView: WKWebView?
    
    @objc func roadcostHandleRefresh(_ sender: UIRefreshControl) {
        roadcostWebView?.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.endRefreshing()
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.scrollView.refreshControl?.endRefreshing()
        roadcostSaveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.scrollView.refreshControl?.endRefreshing()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let roadcostURL = navigationAction.request.url {
            let roadcostScheme = roadcostURL.scheme?.lowercased() ?? ""
            if roadcostScheme != "http" && roadcostScheme != "https" {
                UIApplication.shared.open(roadcostURL)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let roadcostURL = navigationAction.request.url {
            webView.load(URLRequest(url: roadcostURL))
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let roadcostAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        roadcostAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        
        if let roadcostScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let roadcostVC = roadcostScene.windows.first?.rootViewController {
            roadcostVC.present(roadcostAlert, animated: true)
        } else {
            completionHandler()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let roadcostAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        roadcostAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        roadcostAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        
        if let roadcostScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let roadcostVC = roadcostScene.windows.first?.rootViewController {
            roadcostVC.present(roadcostAlert, animated: true)
        } else {
            completionHandler(false)
        }
    }
    
    private func roadcostSaveCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { roadcostCookies in
            let roadcostCookiesArray = roadcostCookies.map { $0.properties ?? [:] }
            if let roadcostData = try? NSKeyedArchiver.archivedData(withRootObject: roadcostCookiesArray, requiringSecureCoding: false) {
                UserDefaults.standard.set(roadcostData, forKey: "roadcost_saved_cookies_v1")
            }
        }
    }
}
