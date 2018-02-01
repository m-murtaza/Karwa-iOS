//
//  BookingConfermationPopupVC.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 2/1/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class BookingConfermationPopupVC: PopupVC {

    @IBOutlet weak var txtPickupHint: UITextField!
    public weak var previousView : KTCreateBookingViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BookingConfermationPopupVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
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
