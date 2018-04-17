//
//  KTRatingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTRatingViewDelegate {
    
    func closeRating()
}
class KTRatingViewController: PopupVC {

    var delegate : KTRatingViewDelegate?
    private var vModel : KTRatingViewModel?
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTRatingViewModel(del: self)
            vModel = viewModel as? KTRatingViewModel
        }
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func booking(_ b: KTBooking) {
        vModel?.booking = b
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btnRateBookingTapped(_ sender: Any) {
        vModel?.rateBooking()
    }
    
    func closeScreen() {
        delegate?.closeRating()
        
    }
    override func showError(title:String, message:String)
    {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.closeScreen()
        }
        
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
        /*let altError = UIAlertController(title: title,message: message,preferredStyle:UIAlertControllerStyle.alert)
        
        altError.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:nil ))
        self.present(altError,animated: true, completion: nil)*/
    }
}
