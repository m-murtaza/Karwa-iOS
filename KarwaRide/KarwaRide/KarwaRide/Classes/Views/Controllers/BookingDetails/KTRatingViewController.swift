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
import Spring

protocol KTRatingViewDelegate {
    
    func closeRating(_ rating : Int32)
}
class KTRatingViewController: PopupVC, KTRatingViewModelDelegate, RKTagsViewDelegate {
    
    var delegate : KTRatingViewDelegate?
    private var vModel : KTRatingViewModel?
    
    @IBOutlet weak var driverImgView : UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    
    @IBOutlet weak var ratingDriverLabel: LocalisableLabel!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblTripFare: UILabel!
    @IBOutlet weak var userRating: CosmosView!
    
    @IBOutlet weak var lblConsolationText: UILabel!
    @IBOutlet weak var lblSelectReasonText: UILabel!

    @IBOutlet weak var tagView: RKTagsView!
    @IBOutlet weak var complainComment: SpringButton!
    @IBOutlet weak var complainCommentSeperator: UIView!
    
    @IBOutlet weak var lblPickUpAddress: UILabel!
    @IBOutlet weak var lblDestinationAddress: UILabel!
    
    @IBOutlet weak var lblVehicleType: UILabel!
    @IBOutlet weak var lblNumberOfPassenger: UILabel!


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
        
//        viewPopupUI.layer.cornerRadius = 16
//        btnSubmit.layer.addBorder(edge: UIRectEdge.top, color: UIColor(hexString:"#DEDEDE"), thickness: 1.0)
        
        tagView.textField.textAlignment = NSTextAlignment.center
        
        userRating.didFinishTouchingCosmos = {rating in
            
            self.vModel?.ratingUpdate(rating: rating)
        }
        
        tagView.textFieldAlign = .center
        
        showHideComplainableLabel(show: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*@IBAction func btnSubmitTapped(_ sender: Any) {
        vModel?.rateBooking()
    }*/
    func booking(_ b: KTBooking) {
        
        if vModel == nil {
            viewModel = KTRatingViewModel(del: self)
            vModel = viewModel as? KTRatingViewModel
        }
        vModel?.setBookingForRating(booking: b)
        navigationItem.title = (vModel?.pickupDayAndTime())! + (vModel?.pickupDateOfMonth())!  + (vModel?.pickupMonth())! + (vModel?.pickupYear())!

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showHideComplainableLabel(show: Bool)
    {
        if(complainComment.isHidden)
        {
            self.complainComment.animation = "slideUp"
            self.complainComment.animate()
        }

        UIView.animate(withDuration: 0.5, animations:
        {
            self.complainComment.isHidden = !show
            self.complainCommentSeperator.isHidden = !show
            self.complainComment.setNeedsDisplay()
            self.complainCommentSeperator.setNeedsDisplay()
            self.view.layoutIfNeeded()
                        
        })
    }
    
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
    
    func showSelectReasonText(message: String) {
        lblSelectReasonText.text = message
        lblSelectReasonText.isHidden = false
    }
    
    func hideConsolationText() {
        lblConsolationText.isHidden = true
    }
    
    func showAltForThanks(rating: Int32)
    {
        showOkDialog(rating)
    }
    
    func showOkDialog(_ rating : Int32)
    {
        closeScreen(rating)
    }
    
    func updateDriver(name: String) {
        lblDriverName.text = name
    }
    
    func updateDriver(rating: Double) {
        ratingDriverLabel.addLeading(image: #imageLiteral(resourceName: "star_ico"), text: String(format: "%.1f", rating as! CVarArg), imageOffsetY: 0)
    }
    
    func updateTrip(fare: String) {
        lblTripFare.text = fare
        
        var iconImage = UIImage()
        iconImage = UIImage(named: ImageUtil.getSmallImage(vModel?.paymentMethodIcon() ?? "")) ?? UIImage()
        lblTripFare.addLeading(image: iconImage, text: fare, imageOffsetY: -5)
        lblNumberOfPassenger.text = vModel?.getPassengerCountr()
        lblVehicleType.text = vModel?.vehicleType()
    
    }
    
    func updateDriverImage(url: URL) {
        driverImgView.kf.setImage(with: url)
    }
    
    func updatePickUpAddress(address: String) {
        lblPickUpAddress.text = address
    }
    
    func updateDropAddress(address: String) {
        lblDestinationAddress.text = address

    }
    
    func hideSystemRating() {
        ratingDriverLabel.isHidden = true
    }
    
    func updatePickup(date: String) {
//        lblPickDateTime.text = date
    }
    
    @IBAction func btnRateBookingTapped(_ sender: Any) {
        vModel?.btnRattingTapped()
    }
    
    func setTitleBtnSubmit(label: String)
    {
        btnSubmit.setTitle(label, for: .normal)
    }
    
    func closeScreen(_ rating : Int32) {
        delegate?.closeRating(rating)
    }

    override func showError(title:String, message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "ok".localized(), style: .default) { (UIAlertAction) in
            self.closeScreen(-1)
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

        if(vModel?.isComplainable(atIndex: index) ?? false)
        {
            btn.setComplainable(true)
        }
        
        btn.setTitleColor(UIColor(hexString:"#006170"), for: UIControlState.normal)

        btn.setTitleColor(UIColor.white, for: UIControlState.selected)
        
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(KTRatingViewController.tagViewTapped), for: .touchUpInside)
        return btn
    }
    @IBAction func complainCommentBtnTapped(_ sender: Any)
    {
        showRatingCommentPopup()
    }

    func showRatingCommentPopup()
    {
        let ratingCommentPopup = storyboard?.instantiateViewController(withIdentifier: "RatingPopupVC") as! RatingCommentPopupVC
        ratingCommentPopup.previousComments = vModel?.remarks ?? ""
        ratingCommentPopup.previousView = self
        ratingCommentPopup.view.frame = self.view.bounds
        view.addSubview(ratingCommentPopup.view)
        addChildViewController(ratingCommentPopup)
    }

    func saveComment(_ comment: String)
    {
        complainComment.setTitle(comment, for: .normal)
        vModel?.remarks = comment
        if(comment.length == 0)
        {
            resetComplainComment()
        }
    }
    
    func removeComment()
    {
        resetComplainComment()
        vModel?.remarks = ""
    }
    
    func resetComplainComment()
    {
        complainComment.setTitle("str_add_comment_here".localized(), for: .normal)
    }
    
    @objc func tagViewTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
        {
            self.vModel?.tagViewTapped()
        }
    }
    
    func selectedIdx() ->[NSNumber] {
        return tagView.selectedTagIndexes
    }
    
//    @objc func buttonAction(sender: UIButton!) {
//        //print("Button Clicked")
//        //sender.backgroundColor = UIColor.red
//    }
}
