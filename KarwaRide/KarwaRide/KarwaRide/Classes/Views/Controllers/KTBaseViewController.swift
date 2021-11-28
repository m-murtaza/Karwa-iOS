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
import EasyTipView

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
        
      altError.addAction(UIAlertAction(title: "ok".localized(), style: UIAlertActionStyle.default, handler:nil ))
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
    
    func showPopupMessage(_ title: String, _ message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "ok".localized(), style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showTaskCompleted(withMessage msg: String) {
        showSuccessBanner("", msg)
//        SVProgressHUD.show(UIImage(named: "light-check-mark")!, status: msg)
//        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func userIntraction(enable: Bool) {
        
        if enable {
            
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        else {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        
        }
    }
    
    //MARK: Get VC From Storyborad
    func getVC(storyboard: Storyboard, vcIdentifier : String) -> UIViewController {
        if #available(iOS 13.0, *) {
            return UIStoryboard(name: storyboard.board(), bundle: nil).instantiateViewController(identifier: vcIdentifier)
        } else {
            return UIStoryboard(name: storyboard.board(), bundle: nil).instantiateViewController(withIdentifier: vcIdentifier)
        }
    }
    
    func showToolTip(forView: UIView) {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hexString: "#129793")
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        preferences.animating.dismissTransform = CGAffineTransform(translationX: 0, y: -15)
        preferences.animating.showInitialTransform = CGAffineTransform(translationX: 0, y: -15)
        preferences.animating.showInitialAlpha = 0
        preferences.animating.showDuration = 1.5
        preferences.animating.dismissDuration = 1.5
        preferences.animating.dismissOnTap = false

        let tipView = EasyTipView(text: "str_promotion_tip".localized(), preferences: preferences, delegate: nil)
        tipView.show(forView: forView)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            tipView.dismiss()
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
    
    func springAnimateButtonTapIn(button btn : SpringButton, transform: CGAffineTransform = CGAffineTransform(scaleX: 0.8, y: 0.8))
    {
        UIView.animate(withDuration: 0.30,
                       animations: {
                        btn.transform = transform
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
        // create a new style
        var style = ToastStyle()
        style.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        style.messageFont = UIFont(name: "MuseoSans-500", size: 13.0)!
        style.messageColor = .white
        style.cornerRadius = 20
        
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: style)

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
    
    func showOkDialog(titleMessage title: String, descMessage desc: String)
    {
        showOkDialog(titleMessage: title, descMessage: desc)
        { (UIAlertAction) in }
    }
    
    func showOkDialog(titleMessage title: String, descMessage desc: String, completion: ((UIAlertAction) -> Void)? = nil)
    {
        let alertController = UIAlertController(title: title, message: desc, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "ok".localized(), style: .default, handler: completion)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
