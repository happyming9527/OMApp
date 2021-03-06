//
//  TestWebViewController.swift
//  WebView
//
//  Created by mlibai on 2017/5/12.
//  Copyright © 2017年 mlibai. All rights reserved.
//

import UIKit
import XZKit
import OMKit

extension Notification.Name {
    static let OMHTMLOpenPageTest = Notification.Name(rawValue: "OMHTMLOpenPageTest")
}

extension WebViewEvent {
    static let theme = WebViewEvent(rawValue: "theme")
}

class OnemenaBrowser: WebViewController, NavigationBarCustomizable, NavigationGestureDrivable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigationBar.barTintColor = UIColor(rgb: 0x3e84e0)
        
        let ua = UIWebView.userAgent
        if !ua.contains("Onemena") {
            UIWebView.userAgent = ua + " Onemena/" + Bundle.main.shortVersionString
        }
        
         guard let url = Bundle.main.url(forResource: "OMApp", withExtension: "js") else { return }
         guard let js = try? String(contentsOf: url) else { return }
         _ = webView.stringByEvaluatingJavaScript(from: js)
    }
    
    override func didRecevie(_ event: WebViewEvent, parameters: [String : Any]?) {
        switch event {
        case WebViewEvent.login:
            loginHandler(parameters)
            
        case WebViewEvent.open:
            openHandler(parameters)
            
        case WebViewEvent.theme:
            guard let name = parameters?["name"] as? String else { return }
            switch name {
            case "day":
                view.brightness = 1.0
            default:
                view.brightness = 0.5
            }
        default:
            super.didRecevie(event, parameters: parameters)
        }
    }
    
    var taskID: String?
    
    func loginHandler(_ parameters: [String : Any]?) -> Void {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginTableViewController
        viewController.delegate = self
        self.taskID = parameters?["taskID"] as? String
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func openHandler(_ parameters: [String : Any]?) {
        guard let viewControllers = tabBarController?.viewControllers else { return }
        guard viewControllers.count > 1 else {
            return
        }
        guard let testNavigationController = viewControllers[1] as? UINavigationController else { return }
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "open") as! OpenViewController
        viewController.rawValue = parameters?.description
        viewController.pageName = parameters?["page"] as? String
        viewController.pageID = parameters?["id"] as? String
        var vcs = testNavigationController.viewControllers
        vcs.append(viewController)
        testNavigationController.setViewControllers(vcs, animated: false)
        
        self.tabBarController?.selectedIndex = 1
        
        guard let rootVC = self.navigationController?.viewControllers.first else { return }
        self.navigationController?.setViewControllers([rootVC], animated: false)
    }

    
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
    }
}

extension OnemenaBrowser: LoginTableViewControllerDelegate {
    
    func loginViewController(_ viewController: LoginTableViewController, didFinishLoginingWith result: String) {
        guard let taskID = self.taskID else { return }
        _ = webView.stringByEvaluatingJavaScript(from: "omApp.didFinishLogining('\(taskID)', \(result))")
        self.taskID = nil
    }
    
}
