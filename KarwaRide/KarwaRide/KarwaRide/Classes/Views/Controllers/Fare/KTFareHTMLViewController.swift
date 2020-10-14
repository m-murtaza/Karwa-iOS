//
//  KTFareHTMLViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import WebKit

class KTFareHTMLViewController: KTBaseDrawerRootViewController,WKNavigationDelegate,WKUIDelegate {

    let url = "https://consumerhelp.karwatechnologies.com/"
    var isFeedback = false
    
    @IBOutlet weak var webView : WKWebView?

    override func viewDidLoad() {

        super.viewDidLoad()
        
        title = isFeedback ? "Feedback" : "Help"
        
        // Do any additional setup after loading the view.
        webView?.navigationDelegate = self //as! WKNavigationDelegate

        let urlWithTimeAndSessionId = isFeedback ? "\(url)?sid=\(KTAppSessionInfo.currentSession.sessionId!)/#Feedback" : "\(url)?sid=\(KTAppSessionInfo.currentSession.sessionId!)"
        
        let request = URLRequest(url: URL(string: urlWithTimeAndSessionId)!)

        showProgressHud(show: true)

        webView?.load(request)
    }

    @IBAction func backPressed(_ sender: Any) {
        
        sideMenuViewController?.contentViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
        sideMenuViewController?.hideMenuViewController()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigating to url \(String(describing: webView.url))")
        hideProgressHud()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func currentTimeInMilliSeconds() -> Int
    {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}
