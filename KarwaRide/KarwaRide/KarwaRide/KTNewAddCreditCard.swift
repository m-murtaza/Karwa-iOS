//
//  KTNewAddCreditCard.swift
//  KarwaRide
//
//  Created by Sam Ash on 13/12/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation
import WebKit
import Lottie

class KTNewAddCreditCard: KTBaseDrawerRootViewController, KTNewAddCreditCardVMDelegate, WKNavigationDelegate, WKUIDelegate,  WKScriptMessageHandler {

//    @IBOutlet weak var ktWebView: WKWebView!

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var swipCardAnim: AnimationView!
    @IBOutlet weak var cardSuccessAnim: AnimationView!

    @IBOutlet weak var lblVerifyingCardInfo: UILabel!
    @IBOutlet weak var lblCardAddedSuccess: UILabel!
    
    var walletController: KTWalletViewController!

    private var vModel : KTNewAddCreditCardVM?

    override func viewDidLoad() {

        super.viewDidLoad()

        webView.configuration.userContentController.add(self, name: "karwa_hook")

        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        
        if viewModel == nil {
            viewModel = KTNewAddCreditCardVM(del: self)
        }

        self.vModel = viewModel as? KTNewAddCreditCardVM
        
        swipCardAnim.isHidden = true
        cardSuccessAnim.isHidden = true
        lblVerifyingCardInfo.isHidden = true
        lblCardAddedSuccess.isHidden = true

        vModel?.viewDidLoad()
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

        if urlAsString.range(of: "gateway3ds2://3dsecure/?result=true") != nil
        {
            startCardSuccessAnim()
            KTPaymentManager().fetchPaymentsFromServer { (status, response) in
                self.walletController.vModel?.fetchnPaymentMethods()
                self.walletController.reloadTable()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.dismiss() }
        }
        else if urlAsString.range(of: "gateway3ds2://3dsecure/?result=false") != nil
        {
            showErrorMsg()
        }
        else if urlAsString.range(of: "result=success") != nil
        {
            showHideWebView(hide: true)
            startCardValidationAnim()
            vModel?.updateSession()
        }
        else if urlAsString.range(of: "result=false") != nil
        {
            showHideWebView(hide: true)
            startCardValidationAnim()
            vModel?.updateSession()
        }
        else if urlAsString.range(of: "result=failed&message") != nil
        {
            showErrorMsg(title: "str_oops".localized(), msg: self.vModel?.getErrorMsg(response: urlAsString) ?? "please_dialog_msg_went_wrong".localized())
        }
    }
    
    func showHideWebView(hide: Bool)
    {
        webView.isHidden = hide
    }
    
    func showErrorMsg(){
        showErrorMsg(title: "str_oops".localized(), msg: "please_dialog_msg_went_wrong".localized())
    }
    
    func showErrorMsg(title: String, msg: String)
    {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "str_ok".localized(), style: .default) { (UIAlertAction) in self.dismiss()}

        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onCrossPressed(_ sender: Any) {
        dismiss()
    }

    func startCardSuccessAnim(){
        lblVerifyingCardInfo.isHidden = true
        lblCardAddedSuccess.isHidden = false
        cardSuccessAnim.isHidden = false
        cardSuccessAnim.loopMode = .loop
        cardSuccessAnim.play()
    }
    
    func startCardValidationAnim(){
        lblCardAddedSuccess.isHidden = true
        lblVerifyingCardInfo.isHidden = false
        swipCardAnim.isHidden = false
        swipCardAnim.loopMode = .loop
        swipCardAnim.play()
    }
    
    func stopCardValidationAnim(){
        lblVerifyingCardInfo.isHidden = true
        swipCardAnim.stop()
        swipCardAnim.isHidden = true
    }
    
    @IBAction func crossPressed(_ sender: Any) {
        closeView()
    }

    func loadURL(url: String) {

        let urlRequest: URL = URL(string: url)!

        self.webView.load(URLRequest(url: urlRequest))
    }
    
    func loadHTML(html: String) {
        self.webView.loadHTMLString(html, baseURL: nil)
    }
    
    func closeView() {
        dismiss()
    }
}
