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
    let promoURL = "https://www.karwa.qa/promo/\(Locale.current.identifier.replacingOccurrences(of: "_", with: "-").lowercased())/promo.html"
    var isFeedback = false
    var isPromotion = false
    
    @IBOutlet weak var webView : WKWebView?

    override func viewDidLoad() {

        super.viewDidLoad()

        title = "Help"
        var urlWithTimeAndSessionId = "\(url)?sid=\(KTAppSessionInfo.currentSession.sessionId!)"

        if(isFeedback)
        {
            urlWithTimeAndSessionId = "\(url)/complaint/Feedback?sid=\(KTAppSessionInfo.currentSession.sessionId!)"
            title = "Feedback"
        }
        else if(isPromotion)
        {
            urlWithTimeAndSessionId = promoURL
            title = "Promotions"
        }

        // Do any additional setup after loading the view.
        webView?.navigationDelegate = self //as! WKNavigationDelegate
        
        let request = URLRequest(url: URL(string: urlWithTimeAndSessionId)!)

        showProgressHud(show: true)

        webView?.load(request)
    }

    @IBAction func backPressed(_ sender: Any) {
      sideMenuController?.contentViewController  = self.storyboard?.instantiateViewController(withIdentifier: "BookingNavigationViewController")
      sideMenuController?.hideMenu()
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
