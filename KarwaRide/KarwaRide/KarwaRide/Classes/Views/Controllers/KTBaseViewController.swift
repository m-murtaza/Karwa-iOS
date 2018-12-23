//
//  KSBaseViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 7/3/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import SVProgressHUD
import Spring
import Toast_Swift
import NotificationBannerSwift

class KTBaseViewController: UIViewController,KTViewModelDelegate {
    
    var viewModel : KTBaseViewModel?

    override func viewDidLoad() {
        delay = 0
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
        (UIApplication.shared.delegate as! AppDelegate).setCurrentViewController(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
        (UIApplication.shared.delegate as! AppDelegate).setCurrentViewController(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func showError(title:String, message:String)
    {
        let altError = UIAlertController(title: title,message: message,preferredStyle:UIAlertControllerStyle.alert)
        
        altError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil ))
        self.present(altError,animated: true, completion: nil)
    }
    
    func showProgressHud(show : Bool, status:String){
        if show {
            SVProgressHUD.show(withStatus: status)
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
        
    }
    func hideProgressHud() {
        
        showProgressHud(show: false)
    }
    
    func showProgressHud(show: Bool) {
        if show {
            SVProgressHUD.show();
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
    }
    
    func showTaskCompleted(withMessage msg: String) {
        SVProgressHUD.show(UIImage(named: "light-check-mark")!, status: msg)
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func userIntraction(enable: Bool) {
        
        if enable {
            
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        else {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        
        }
    }
    
    func viewStoryboard() -> UIStoryboard {
        return self.storyboard!
        
    }
    
    func dismiss()  {
        self.dismiss(animated: true, completion: nil)
    }

    func performSegue(name:String) {
        
        self.performSegue(withIdentifier: name, sender: self)
    }
    

    func isLargeScreen() -> Bool {
        var large : Bool = false
        let horizontalClass : UIUserInterfaceSizeClass = self.traitCollection.horizontalSizeClass
        let verticalCass : UIUserInterfaceSizeClass  = self.traitCollection.verticalSizeClass;
        
        if horizontalClass == .regular && verticalCass == .regular {
            large = true
        }
        return large
    }
    
    func springAnimateButtonTapIn(button btn : SpringButton)
    {
        UIView.animate(withDuration: 0.30,
                       animations: {
                        btn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func springAnimateButtonTapIn(imageView image : SpringImageView)
    {
        UIView.animate(withDuration: 0.30,
                       animations: {
                        image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func springAnimateButtonTapOut(button btn : SpringButton)
    {
        UIView.animate(withDuration: 0.35) {
            btn.transform = CGAffineTransform.identity
        }
    }
    
    func springAnimateButtonTapOut(imageView image : SpringImageView)
    {
        UIView.animate(withDuration: 0.35) {
            image.transform = CGAffineTransform.identity
        }
    }
    
    func showToast(message : String)
    {
        self.view.makeToast(message)
//        // create a new style
//        var style = ToastStyle()
//        style.backgroundColor = .white
//        style.messageFont = .systemFont(ofSize: 13)
//        style.messageColor = .black
//        
//        self.view.makeToast(message, duration: 3.0, position: .bottom, style: style)

    }
    
    var delay : Double = 0.1
    
    func animateCell(_ cell: UITableViewCell, delay animDelay: Double)
    {
        if(animDelay == 0)
        {
            delay = animDelay
        }
        animateCell(cell)
    }
    
    func animateCell(_ cell: UITableViewCell)
    {
        let top = CGAffineTransform(translationX: 0, y: -1500)
        
        UIView.animate(withDuration: 0.7, delay: delay, options: [], animations: {
            // Add the transformation in this block
            // self.container is your view that you want to animate
            cell.transform = top
        }, completion: nil)
        
        delay = delay + 0.1
    }

    func showSuccessBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.success)
    }
    
    func showInfoBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.info)
    }
    
    func showErrorBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.danger)
    }
    
    func showNonBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.none)
    }
    
    func showWarningBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.warning)
    }

    func showBanner(_ title: String, _ message: String, _ bannerStyle: BannerStyle)
    {
        let banner = NotificationBanner(title: title, subtitle: message, style: bannerStyle)
        banner.show()
        DispatchQueue.main.asyncAfter(deadline: (.now() + 4))
        {
            banner.dismiss()
        }
    }
    
    func updateForBooking(_ booking: KTBooking)
    {
        //Over-ridden in KTBookingDetailsViewController
        print("Over-ridden in KTBookingDetailsViewController")
    }
}
