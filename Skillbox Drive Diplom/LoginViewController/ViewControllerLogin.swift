//
//  ViewController.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 29.07.2022.
//

import UIKit
import WebKit

class ViewControllerLogin: UIViewController, ViewControllerLoginProcotol {
    
    var viewModel: ViewModelLoginProtocol? = ViewModelLogin()
    
    var token: String?
    var clientId: String = "5401010f4dec40278d656c024750f2db"
    var isOnboardHidden: Bool = false
    
    private lazy var webView: WKWebView = {
        let webConfig = WKWebViewConfiguration()
        let webview = WKWebView(frame: .zero, configuration: webConfig)
        return webview
    }()
    
    @IBAction func loginButton(_ sender: Any) {
        let vcWeb = UIViewController()
        vcWeb.view = webView
        guard let request = viewModel?.loginOauth() else { return }
        webView.load(request)
        present(vcWeb, animated: true, completion: nil)
    }
    
    func presentMainView() {
        if let _ = token {
            let vc = createMainTabBar()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func presentOnboardViewController() {
        let onBoard = viewModel?.createOnboardViewController()
        onBoard?.presentFrom(self, animated: true)
    }
    
    private func createMainTabBar() -> UITabBarController {
        let vc1 = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "PersonTabBarVC")
        let vc2 = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "RecentVC")
        let vc3 = UIStoryboard(name: "MainTabBar", bundle: nil).instantiateViewController(withIdentifier: "AllFilesTabBarVC")
        let nv1 = UINavigationController(rootViewController: vc1)
        let nv2 = UINavigationController(rootViewController: vc2)
        let nv3 = UINavigationController(rootViewController: vc3)
        let tc = UITabBarController()
        tc.viewControllers = [nv1, nv2, nv3]
        return tc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        webView.navigationDelegate = self
        
        token = UserDefaults.standard.string(forKey: "token")
        presentMainView()
        
        isOnboardHidden = UserDefaults.standard.bool(forKey: "isOnboardHidden")
        
        if isOnboardHidden == false {
            viewModel?.presentOnboardViewController()
        }
    }
    
    func changeIsOnboardHidden() {
        isOnboardHidden = !isOnboardHidden
    }
}

extension ViewControllerLogin: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, url.scheme == "ydisk" {
            decisionHandler(.allow)
            let urlStr = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            let urlComp = URLComponents(string: urlStr)
            let token = urlComp?.queryItems?.first?.value
            self.token = token
            UserDefaults.standard.set(token, forKey: "token")
            dismiss(animated: true, completion: nil)
            let vc = createMainTabBar()
            self.navigationController?.pushViewController(vc, animated: false)
        } else {
            decisionHandler(.allow)
        }
    }
}
