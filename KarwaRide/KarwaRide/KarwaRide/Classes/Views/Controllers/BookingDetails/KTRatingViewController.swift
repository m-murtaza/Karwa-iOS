//
//  KTRatingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos
import RKTagsView
import SAConfettiView

protocol KTRatingViewDelegate {
    
    func closeRating()
}
class KTRatingViewController: PopupVC, KTRatingViewModelDelegate, RKTagsViewDelegate {
    
    var delegate : KTRatingViewDelegate?
    private var vModel : KTRatingViewModel?
    
    @IBOutlet weak var driverImgView : UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var ratingDriverSystem: CosmosView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblTripFare: UILabel!
    @IBOutlet weak var lblPickDateTime: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    @IBOutlet weak var lblConsolationText: UILabel!
    @IBOutlet weak var tagView: RKTagsView!
    
    @IBAction func testbtnTapped(_ sender: Any) {
        (sender as! UIButton).backgroundColor = UIColor.blue
    }
    override func viewDidLoad() {
        if viewModel == nil {
            viewModel = KTRatingViewModel(del: self)
            vModel = viewModel as? KTRatingViewModel
        }
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateUIForImageView()
        
        viewPopupUI.layer.cornerRadius = 16
        btnSubmit.layer.addBorder(edge: UIRectEdge.top, color: UIColor(hexString:"#DEDEDE"), thickness: 1.0)
        
        tagView.textField.textAlignment = NSTextAlignment.center
        
        userRating.didFinishTouchingCosmos = {rating in
            
            self.vModel?.ratingUpdate(rating: rating)
        }
        
        tagView.textFieldAlign = .center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func btnSubmitTapped(_ sender: Any) {
        vModel?.rateBooking()
    }*/
    func booking(_ b: KTBooking) {
        vModel?.setBookingForRating(booking: b) 
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateUIForImageView() {
        
        driverImgView.layer.cornerRadius = driverImgView.frame.size.width / 2
        driverImgView.clipsToBounds = true
        driverImgView.layer.borderWidth = 3.0
        driverImgView.layer.borderColor = UIColor.white.cgColor
    }
    
    //MARK: - Delegates
    func enableSubmitButton() {
        self.btnSubmit.isEnabled = true
    }
    
    func showConsolationText() {
        lblConsolationText.isHidden = false
    }
    func showConsolationText(message: String) {
        lblConsolationText.text = message
        lblConsolationText.isHidden = false
    }
    func hideConsolationText() {
        lblConsolationText.isHidden = true
    }
    
    func showAltForThanks(rating: Int32)
    {
        let confettiView = SAConfettiView(frame: self.view.bounds)
        let isAppStoreRatingDone = SharedPrefUtil.getSharePref(SharedPrefUtil.IS_APP_STORE_RATING_DONE)
        
        if(rating > 3)
        {
            confettiView.type = .Diamond
            confettiView.colors = [UIColor.yellow]
            confettiView.intensity = 0.75
            
            view.addSubview(confettiView)
            confettiView.startConfetti()

            if(isAppStoreRatingDone.isEmpty || isAppStoreRatingDone.count == 0)
            {
                // Asking for App Store Rating
                showRatingDialog(confettiView, rating)
            }
            else
            {
                // Show Normal OK Dialog
                showOkDialog(confettiView, rating)
            }
        }
        else
        {
            showOkDialog(confettiView, rating)
        }
    }
    
    func showOkDialog(_ confettiView : SAConfettiView, _ rating : Int32)
    {
        let alertController = UIAlertController(title: "", message: "Thanks for providing us your valuable feedback", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            if(rating > 3)
            {
                confettiView.stopConfetti()
            }
            
            self.closeScreen()
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)

    }

    func showRatingDialog(_ confettiView : SAConfettiView, _ rating : Int32)
    {
        SharedPrefUtil.setSharedPref(SharedPrefUtil.IS_APP_STORE_RATING_DONE, "true")
        
        let alert = UIAlertController(title: "Thank you", message: "Please rate us on App Store", preferredStyle: .alert)
        
        let rateAction = UIAlertAction(title: "Rate", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            if(rating > 3)
            {
                confettiView.stopConfetti()
            }
            self.closeScreen()
            self.vModel?.rateApplication()
        }
        let notNowAction = UIAlertAction(title: "Not Now", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            if(rating > 3)
            {
                confettiView.stopConfetti()
            }
            self.closeScreen()
        }
        
        alert.addAction(rateAction)
        alert.addAction(notNowAction)
        
        self.present(alert, animated: true)
    }
    
    func updateDriver(name: String) {
        lblDriverName.text = name
    }
    
    func updateDriver(rating: Double) {
        ratingDriverSystem.rating = rating
    }
    
    func updateTrip(fare: String) {
        lblTripFare.text = fare
    }
    
    func updateDriverImage(url: URL) {
        driverImgView.kf.setImage(with: url)
    }
    
    func hideSystemRating() {
        ratingDriverSystem.isHidden = true
    }
    
    func updatePickup(date: String) {
        lblPickDateTime.text = date
    }
    
    @IBAction func btnRateBookingTapped(_ sender: Any) {
        vModel?.btnRattingTapped()
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
    
    func userFinalRating() -> Int32 {
        return Int32(userRating.rating)
    }
    
    //MARK:- Rating view
    
    func removeAllTags() {
        tagView.removeAllTags()
    }
    
    func addTag(tag: String) {
        tagView.addTag(tag)
    }
    
    func tagsView(_ tagsView: RKTagsView, buttonForTagAt index: Int) -> UIButton {
        tagView.scrollView.flashScrollIndicators()
        let btn: KTTagButton = KTTagButton(type:UIButtonType.custom)
        btn.setTitle(vModel?.reason(atIndex: index), for: UIControlState.normal)
        btn.setTitleColor(UIColor(hexString:"#5B5A5A"), for: UIControlState.normal)
        btn.setTitleColor(UIColor.white, for: UIControlState.selected)
        
        btn.adjustsImageWhenHighlighted = false
        //btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return btn
    }
    
    func selectedIdx() ->[NSNumber] {
        return tagView.selectedTagIndexes
    }
    
//    @objc func buttonAction(sender: UIButton!) {
//        //print("Button Clicked")
//        //sender.backgroundColor = UIColor.red
//    }
}
