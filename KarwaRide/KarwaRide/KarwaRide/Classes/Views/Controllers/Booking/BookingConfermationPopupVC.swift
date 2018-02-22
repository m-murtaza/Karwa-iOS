//
//  BookingConfermationPopupVC.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/1/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import QuartzCore

class BookingConfermationPopupVC: PopupVC {

    @IBOutlet weak var txtPickupHint: UITextField!
    @IBOutlet weak var btnClose : UIButton!
    @IBOutlet weak var btnConfirm : UIButton!
    public weak var previousView : KTCreateBookingViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        viewPopupUI.layer.cornerRadius = 18;
        viewPopupUI.layer.masksToBounds = true;
        btnClose.layer.borderWidth = 0.5
        btnClose.layer.borderColor = UIColor.lightGray.cgColor
        btnConfirm.layer.borderWidth = 0.5
        btnConfirm.layer.borderColor = UIColor.lightGray.cgColor
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height/2
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnBookedTapped(_ sender: Any) {
        if txtPickupHint.text != nil && txtPickupHint.text != "" {
            previousView?.pickupHint = txtPickupHint.text!
        }
        previousView?.bookRide()
        self.hideViewWithAnimation()
    }
    @IBAction func btnCancelTapped(_ sender: Any) {
        self.hideViewWithAnimation()
    }
}
