//
//  KTCyberSecureViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 18/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import WebKit

protocol WebViewDelegate {
    func getUpdatedTransactions()
}

extension WebViewDelegate {
    func getUpdatedTransactions() {
        
    }
}

class KTCyberSecureViewController: KTBaseViewController, WKNavigationDelegate, WKUIDelegate,  WKScriptMessageHandler {
    
    @IBOutlet weak var webview: WKWebView!
    
    var delegate: WebViewDelegate?

    var paymentLink: String = ""
    
    var paymentSuccess: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView(
            frame: CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: self.webview.frame.size.height))

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.configuration.userContentController.add(self, name: "karwa_hook")

        self.view.addSubview(webView)
        let url: URL = URL(string: paymentLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        webView.load(URLRequest(url: url))
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func onSuccess() {
        
        print("success called")
        //self.dismiss(animated: true, completion: nil)
    }
    
    func onFailure(message: String) {
        
        print("failure called", message)

//        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeViewController() {
        self.dismiss()
    }
    
}

extension KTCyberSecureViewController {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        //This function handles the events coming from javascript. We'll configure the javascript side of this later.
        //We can access properties through the message body, like this:
        guard let response = message.body as? String else { return }
        print(response)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //This function is called when the webview finishes navigating to the webpage.
        //We use this to send data to the webview when it's loaded.
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
            return
        }
        
        if urlAsString.range(of: "message=success") != nil {
            // do something
            self.paymentSuccess = true
        }else if urlAsString.range(of: "/paymentresponse.html?result=true") != nil {
            if self.paymentSuccess == true {
                self.delegate?.getUpdatedTransactions()
                self.closeViewController()
            } else {
                self.showError(title: "Payment Failed", message: "")
            }
        }

    }

}
