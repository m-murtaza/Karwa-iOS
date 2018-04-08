//
//  CancelViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/5/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCancelViewController: PopupVC,KTCancelViewModelDelegate {

    public weak var previousView : KTBookingDetailsViewController?
    
    var bookingStatii : Int32 = 0
    var bookingId : String = ""
    
    private var vModel : KTCancelViewModel?
    override func viewDidLoad() {
    
        if viewModel == nil {
            viewModel = KTCancelViewModel(del: self)
            vModel = viewModel as? KTCancelViewModel
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewPopupUI.layer.cornerRadius = 16
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
    
    func getBookingStatii() -> Int32 {
        
        return bookingStatii
    }
}
