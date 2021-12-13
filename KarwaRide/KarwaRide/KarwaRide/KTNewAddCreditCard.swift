//
//  KTNewAddCreditCard.swift
//  KarwaRide
//
//  Created by Sam Ash on 13/12/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import WebKit

class KTNewAddCreditCard: KTBaseDrawerRootViewController, KTNewAddCreditCardVMDelegate, WKNavigationDelegate, WKUIDelegate,  WKScriptMessageHandler {

    @IBOutlet weak var ktWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        ktWebView.navigationDelegate = self
        ktWebView.uiDelegate = self
        ktWebView.configuration.userContentController.add(self, name: "karwa_hook")
    }
    
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
        
        print("Receiving urlAsString: ")
        print(urlAsString)

//        if urlAsString.range(of: "message=success") != nil
//        {
//            self.paymentSuccess = true
//        }
//        else if urlAsString.range(of: "/paymentresponse.html?result=true") != nil
//        {
//            if self.paymentSuccess == true
//            {
//                self.delegate?.getUpdatedTransactions()
//                self.closeViewController()
//            }
//            else
//            {
//                self.showError(title: "Payment Failed", message: "")
//            }
//        }

    }
    
    func onCardSuccess() {
        print("onCardSuccess called")
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        closeView()
    }
    
    func loadURL(url: String) {

        let urlRequest: URL = URL(string: url)!

        ktWebView.load(URLRequest(url: urlRequest))
    }
    
    func closeView() {
        dismiss()
    }
}
