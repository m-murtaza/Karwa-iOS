//
//  KTWebViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/14/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import WebKit

class KTWebViewController: KTBaseViewController,WKNavigationDelegate {

    @IBOutlet weak var webView : WKWebView?
    var url : String = ""
    var navTitle : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if title != ""
        {
            self.navigationItem.title = navTitle
        }
        if url != ""
        {
            webView?.navigationDelegate = self //as! WKNavigationDelegate
            let request = URLRequest(url: URL(string: url)!)
            webView?.load(request)
        }
        // Do any additional setup after loading the view.
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
