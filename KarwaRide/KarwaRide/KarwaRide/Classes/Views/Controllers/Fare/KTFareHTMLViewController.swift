//
//  KTFareHTMLViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 6/6/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import WebKit

class KTFareHTMLViewController: KTBaseDrawerRootViewController,WKNavigationDelegate {

    let fareURL = "http://www.karwatechnologies.com/fare.htm"
    let helpURL = "http://stagemursaalapi.karwasolutions.com:9002/"
    
    @IBOutlet weak var webView : WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView?.navigationDelegate = self //as! WKNavigationDelegate
        let request = URLRequest(url: URL(string: helpURL)!)
        webView?.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finished navigating to url \(String(describing: webView.url))")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
