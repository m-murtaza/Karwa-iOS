//
//  UIViewController + Extension.swift
//  KarwaRide
//
//  Created by Umer Afzal on 29/10/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboardOld))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
  func tapToDismissKeyboard() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(dismissKeyboardOld))
    //tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboardOld() {
    view.endEditing(true)
  }
  
  func changeStatusBarColor(color: UIColor = UIColor.primaryLight) {
    if #available(iOS 13.0, *) {
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
        
        let statusbarView = UIView()
        statusbarView.backgroundColor = color
        view.addSubview(statusbarView)
      
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor
            .constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor
            .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor
            .constraint(equalTo: view.topAnchor).isActive = true
        statusbarView.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
      
    } else {
        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
        statusBar?.backgroundColor = color
    }
  }
  
    func setMandatoryUpdateAlert(defaultCloseButton:Bool,message:String) {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton:  defaultCloseButton,
            showCircularIcon: true
        )
        
        let alert = SCLAlertView(appearance:appearance)
        alert.addButton("ok".localized(), target:self, selector:#selector(updateApp))
        
        alert.showWarning("UPDATE".localized(), subTitle: message,closeButtonTitle : "CANCEL".localized())
        

    }
    
    @objc func updateApp(){
        let appUrl = "https://itunes.apple.com/sa/app/mawgif-mwqf/id1006045300?mt=8"
        guard let settingsUrl = URL(string: appUrl) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    // Finished opening URL
                })
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
    }
    
}
