//
//  KTXpressRideCreationViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 30/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit
import Spring
import GoogleMaps
import CDAlertView
import CoreLocation
import ABLoaderView

class KTXpressRideServiceCell: UITableViewCell {
    
    @IBOutlet weak var lblServiceType : UILabel!
    @IBOutlet weak var lblBaseFareOrEstimate : UILabel!
    @IBOutlet weak var imgVehicleType : SpringImageView!
    @IBOutlet weak var imgVehicleBGView : UIImageView!
    @IBOutlet weak var dropDownButton : UIButton!
    @IBOutlet weak var orderRideButton : UIButton!
    @IBOutlet weak var showDetailsButton : UIButton!


    override class func awakeFromNib() {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
      contentView.backgroundColor = selected ? .white : .clear
      contentView.layer.borderColor = selected ? UIColor.primary.cgColor : UIColor.clear.cgColor
      contentView.layer.borderWidth = selected ? 2 : 0
      contentView.layer.cornerRadius = selected ? 8 : 0
      lblServiceType.font = UIFont(name:selected ? "MuseoSans-900" : "MuseoSans-700", size: 16.0)
        lblBaseFareOrEstimate.font = UIFont(name:selected ? "MuseoSans-900" : "MuseoSans-700", size: 14.0)
      if(selected && !animated)
      {
        imgVehicleType.animation = (Locale.current.languageCode?.contains("ar"))! ? "slideLeft" : "slideRight"
        imgVehicleType.animate()
      }
    }
    
}

class KTFareServiceCell: UITableViewCell {
    
    @IBOutlet weak var fareTitleLabel : UILabel!
    @IBOutlet weak var fareStackView : UIStackView!

    override class func awakeFromNib() {
        
    }
    
}


class KTXpressRideCreationViewController: KTBaseCreateBookingController, KTXpressRideCreationViewModelDelegate {
        
    @IBOutlet weak var shimmerView: UIView!
    @IBOutlet weak var shimmerLabeltop1: UILabel!
    @IBOutlet weak var shimmerLabeltop2: UILabel!
    @IBOutlet weak var shimmerImageViewtop: UIImageView!
    
    @IBOutlet weak var shimmerLabelmiddle1: UILabel!
    @IBOutlet weak var shimmerLabelmiddle2: UILabel!
    @IBOutlet weak var shimmerImageViewMiddle: UIImageView!
    
    @IBOutlet weak var shimmerLabelBottom1: UILabel!
    @IBOutlet weak var shimmerLabelBottom2: UILabel!
    @IBOutlet weak var shimmerImageViewBottom: UIImageView!
    
    @IBOutlet weak var rideServiceView: UIView!
    
    @IBOutlet weak var pickUpAddressButton: SpringButton!
    @IBOutlet weak var dropOffAddressButton: SpringButton!
    @IBOutlet weak var setBookingButton: SpringButton!

    @IBOutlet weak var rideServiceTableView: UITableView!
    
    @IBOutlet weak var bookingProgress: UIProgressView!
    
    var operationArea = [Area]()
        
    var rideServicePickDropOffData: RideSerivceLocationData? = nil
    
    var vModel : KTXpressRideCreationViewModel?

    var headerData = [1,2,3,4]
    
    @IBOutlet weak var plusButton: UIButton!

    @IBOutlet weak var minusButton: UIButton!

    @IBOutlet weak var passengerLabel: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var countOfPassenger = 1
    var secondsRemaining:Float = 1.0
    
    var expiryTime = 0
    
    var serverPickUpLocationMarker: GMSMarker!
    var pickUpLocationMarker: GMSMarker!
    var dropOffLocationMarker: GMSMarker!
    
    var poseDuration = 0
    var indexProgressBar = 0
    var currentPoseIndex = 0
    
    var selectedVehicleIndex = 0
    
    @IBOutlet weak var arrowImage: UIImageView!
    
    @IBOutlet weak var walkToPickUpView: UIView!

    override func viewDidLoad() {
        
        rideServiceTableView.bounces = false
        
        super.viewDidLoad()

        setBookingButton.setTitle("book_ride".localized(), for: .normal)

        viewModel = KTXpressRideCreationViewModel(del:self)
        vModel = viewModel as? KTXpressRideCreationViewModel
        
        if xpressRebookSelected == true {
            (viewModel as? KTXpressRideCreationViewModel)?.getDestinationForPickUp()
            (viewModel as? KTXpressRideCreationViewModel)?.getDestination()
        } else {
            vModel?.rideServicePickDropOffData = rideServicePickDropOffData
        }
        
        shimmerView.isHidden = false
        
        vModel?.fetchRideService()
                
        // Do any additional setup after loading the view.
        addMap()
        
        self.navigationItem.hidesBackButton = true;
        
        rideServiceTableView.delegate = self
        rideServiceTableView.dataSource = self
        
        self.pickUpAddressButton.titleLabel?.numberOfLines = 1
        self.dropOffAddressButton.titleLabel?.numberOfLines = 1
        
        self.rideServiceView.isHidden = false
        
        bookingProgress.progress = 0.0
        
        switch rideServicePickDropOffData?.passsengerCount ?? 1 {
        case 1:
            self.passengerLabel.text = "str_1pass".localized()
        case 2:
            self.passengerLabel.text = "str_2pass".localized()
        case 3:
            self.passengerLabel.text = "str_3pass".localized()
        default:
            self.passengerLabel.text = "str_1pass".localized()
        }
        
        if Device.getLanguage().contains("AR") {
            arrowImage.image = #imageLiteral(resourceName: "pickdrop_connected_arrow").imageFlippedForRightToLeftLayoutDirection()
        }
        
        self.pickUpAddressButton.isUserInteractionEnabled = false
        self.dropOffAddressButton.isUserInteractionEnabled = false

        self.setBookingButton.backgroundColor = UIColor(hexString: "#4BA5A7")
        self.setBookingButton.isUserInteractionEnabled = true
        self.setBookingButton.addShadowBottomXpress()
        
        ABLoader().startShining(self.shimmerImageViewtop)
        ABLoader().startShining(self.shimmerLabeltop1)
        ABLoader().startShining(self.shimmerLabeltop2)
        ABLoader().startShining(self.shimmerImageViewMiddle)
        ABLoader().startShining(self.shimmerLabelmiddle1)
        ABLoader().startShining(self.shimmerLabelmiddle2)
        ABLoader().startShining(self.shimmerImageViewBottom)
        ABLoader().startShining(self.shimmerLabelBottom1)
        ABLoader().startShining(self.shimmerLabelBottom2)
        
        self.bookingProgress.trackTintColor = .clear

//        heightConstraint.constant = 250
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func showHideNavigationBar(status: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if self.timer != nil {
            self.timer.invalidate()
        }
    }
    
    @IBAction func showPickUpScreen(_ sender: UIButton) {
        if let navController = self.navigationController {
            if let navController = self.navigationController {

                print(navController.viewControllers.count)
                print(navController.viewControllers)

                if let controller = navController.viewControllers.first(where: { $0 is KTXpressRideCreationViewController }) {
                    if navController.viewControllers.count == 6 {
                        navController.popToViewController(navController.viewControllers[3], animated: true)
                    }else if navController.viewControllers.count > 4 {
                        navController.popToViewController(navController.viewControllers[2], animated: true)
                    } else if navController.viewControllers.count <= 3 {
                        navController.popToViewController(navController.viewControllers[0], animated: true)
                    }
                    else if navController.viewControllers.count <= 4 {
                        navController.popToViewController(navController.viewControllers[1], animated: true)
                    }
                    else {
                        navController.popViewController(animated: true)
                    }
                } else {
                    navController.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func setCountForPassenger(sender: UIButton) {
        
        self.plusButton.isUserInteractionEnabled = false
        self.minusButton.isUserInteractionEnabled = false
        self.plusButton.layer.opacity = 0.4
        self.minusButton.layer.opacity = 0.4


//        if sender.tag == 10 {
//            countOfPassenger = countOfPassenger == 1 ? (countOfPassenger + 1) : countOfPassenger
//        } else {
//            countOfPassenger = countOfPassenger > 1 ? (countOfPassenger - 1) : 1
//        }
//                
//        self.passengerLabel.text = "\(countOfPassenger) \("str_pass".localized())"
//        vModel?.rideServicePickDropOffData?.passsengerCount = countOfPassenger
    }
    
    func setPickup(pick: String?) {
        guard pick != nil else {
            return
        }
        self.pickUpAddressButton.setTitle(pick, for: .normal)
    }
        
    func setDropOff(pick: String?) {
        guard pick != nil else {
            return
        }
        self.dropOffAddressButton.setTitle(pick, for: .normal)
    }
 
    func setProgressViewCounter(countDown: Int) {
//        expiryTime = countDown
        getNextPoseData()
        poseDuration = countDown

      timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(setProgressBar), userInfo: nil, repeats: true)

    }
    
    @objc func updateCounter(){
        if self.bookingProgress.progress > 0 {
            print("\(self.bookingProgress.progress) seconds.")
            
            let change: Float = Float(Float(1) / Float(expiryTime))
            let progress = self.bookingProgress.progress - (change)
            self.bookingProgress.setProgress(progress, animated: true)
            
        } else {
            self.bookingProgress.isHidden = true
            showAlertForTimeOut()
            timer.invalidate()
        }
    }
    
    func getNextPoseData() {
         // do next pose stuff
         currentPoseIndex += 1
         print(currentPoseIndex)
     }

     @objc func setProgressBar() {
         if indexProgressBar == poseDuration {
             getNextPoseData()
             // reset the progress counter
             indexProgressBar = 0
            timer.invalidate()
            self.bookingProgress.isHidden = true
            showAlertForTimeOut()
         } else {
            // update the display
            // use poseDuration - 1 so that you display 20 steps of the the progress bar, from 0...19
           self.bookingProgress.setProgress(Float(indexProgressBar) / Float(poseDuration - 1), animated: true)
           self.bookingProgress.isHidden = false
            // increment the counter
            indexProgressBar += 1
         }
         
     }
    
    func showHideRideServiceView(show: Bool) {
        self.rideServiceView.isHidden = !show
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueXpressBookingListForDetails" {
          
          // Create a variable that you want to send
          //            var newProgramVar = ""
          
          // Create a new variable to store the instance of PlayerTableViewController
          let destinationVC = segue.destination as! KTMyTripsViewController
          destinationVC.setBooking(booking: (viewModel as! KTXpressRideCreationViewModel).booking)
        }
      }
    
    func showAlertForTimeOut() {
        let alert = CDAlertView(title: "str_no_ride".localized(), message: "str_request_ride".localized(), type: .custom(image: UIImage(named:"icon-notifications")!))
        let doneAction = CDAlertViewAction(title: "str_no".localized()) { value in
            
            if let navController = self.navigationController {

                if let controller = navController.viewControllers.first(where: { $0 is KTXpressRideCreationViewController }) {
                    
                    if navController.viewControllers.count == 6 {
                        navController.popToViewController(navController.viewControllers[3], animated: true)
                    } else if navController.viewControllers.count > 4 {
                        navController.popToViewController(navController.viewControllers[2], animated: true)
                    } else if navController.viewControllers.count <= 3 {
                        navController.popToViewController(navController.viewControllers[0], animated: true)
                    } else if navController.viewControllers.count <= 4 {
                        navController.popToViewController(navController.viewControllers[1], animated: true)
                    } else {
                        navController.popViewController(animated: true)
                    }
                    
                } else {
                    navController.popViewController(animated: true)
                }
            }
            return true
        }
        alert.add(action: doneAction)
        let yesAction = CDAlertViewAction(title: "str_yes".localized()) { value in
            self.vModel?.fetchRideService()
            return true
        }
        alert.add(action: yesAction)
        alert.show()
    }
    
    func showAlertForFailedRide(message: String) {
        let alert = CDAlertView(title: message, message: "", type: .error)
        let doneAction = CDAlertViewAction(title: "str_ok".localized()) { value in
            
            if let navController = self.navigationController {

                if let controller = navController.viewControllers.first(where: { $0 is KTXpressRideCreationViewController }) {
                    if navController.viewControllers.count == 6 {
                        navController.popToViewController(navController.viewControllers[3], animated: true)
                    } else if navController.viewControllers.count > 4 {
                        navController.popToViewController(navController.viewControllers[2], animated: true)
                    } else if navController.viewControllers.count <= 3 {
                        navController.popToViewController(navController.viewControllers[0], animated: true)
                    } else if navController.viewControllers.count <= 4 {
                        navController.popToViewController(navController.viewControllers[1], animated: true)
                    } else {
                        navController.popViewController(animated: true)
                    }
                } else {
                    navController.popViewController(animated: true)
                }
            }
            return true
        }
        
        alert.add(action: doneAction)
        alert.show()
    }
        
    func updateUI() {
        if #available(iOS 15.0, *) {
            heightConstraint.constant = CGFloat(223 + (((self.viewModel as! KTXpressRideCreationViewModel).rideInfo?.rides.count ?? 0) * 63))
        } else {
            heightConstraint.constant = CGFloat(200 + (((self.viewModel as! KTXpressRideCreationViewModel).rideInfo?.rides.count ?? 0) * 63))
        }
        self.rideServiceTableView.reloadData()
        shimmerView.isHidden = true

    }

    @IBAction func showRideTrackingViewController() {
        springAnimateButtonTapOut(button: setBookingButton)
        self.timer.invalidate()
        (self.viewModel as! KTXpressRideCreationViewModel).getRide(index: self.selectedVehicleIndex)
        (self.viewModel as! KTXpressRideCreationViewModel).didTapBookButton()
    }
    
    @IBAction func bookbtnTouchDown(_ sender: SpringButton)
    {
      springAnimateButtonTapIn(button: setBookingButton)
    }
    
    @IBAction func bookbtnTouchUpOutside(_ sender: SpringButton)
    {
      springAnimateButtonTapOut(button: setBookingButton)
    }
    
    // ⬇︎⬇︎⬇︎ animation happens here ⬇︎⬇︎⬇︎
      func animateButton() {
        setBookingButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
          UIView.animate(withDuration: 1.0,
          delay: 0,usingSpringWithDamping: CGFloat(0.5),initialSpringVelocity: CGFloat(3.0),
          options: .allowUserInteraction,
          animations: {
            self.setBookingButton.transform = .identity
          },
          completion: { finished in
              DispatchQueue.main.async {
                  self.timer.invalidate()
                  (self.viewModel as! KTXpressRideCreationViewModel).getRide(index: self.selectedVehicleIndex)
                  (self.viewModel as! KTXpressRideCreationViewModel).didTapBookButton()
              }
          }
        )
      }
    
    func showRideTrackViewController() {
        let rideService = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressRideTrackingViewController") as? KTXpressRideTrackingViewController)!
        rideService.rideServicePickDropOffData = rideServicePickDropOffData
        rideService.selectedRide = (self.viewModel as! KTXpressRideCreationViewModel).selectedRide
        
        let details  = (self.storyboard?.instantiateViewController(withIdentifier: "KTXpressBookingDetailsViewController") as? KTXpressBookingDetailsViewController)!
        details.rideServicePickDropOffData = rideServicePickDropOffData

        if let booking : KTBooking = vModel?.selectedBooking {
            details.setBooking(booking: booking)
        }
        self.navigationController?.pushViewController(details, animated: true)        
    }
        
}

extension KTXpressRideCreationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.viewModel as! KTXpressRideCreationViewModel).rideInfo?.rides.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTXpressRideServiceCell") as! KTXpressRideServiceCell
//        cell.showDetailsButton.addTarget(self, action: #selector(addPickupMarker(sender:)), for: .touchUpInside)
        cell.dropDownButton.tag = section
        cell.lblServiceType.text = (self.viewModel as! KTXpressRideCreationViewModel).getVehicleNo(index: section)
        cell.lblBaseFareOrEstimate.attributedText = (self.viewModel as! KTXpressRideCreationViewModel).getEstimatedTime(index: section)
        cell.orderRideButton.addTarget(self, action: #selector(orderVehicle(sender:)), for: .touchUpInside)
        cell.orderRideButton.tag = section
        cell.orderRideButton.isHidden = false
        tableView.backgroundColor = #colorLiteral(red: 0.9033820629, green: 0.9384498, blue: 0.9333658814, alpha: 1)
        if selectedVehicleIndex == section {
            cell.contentView.customBorderWidth = 2
            cell.contentView.customBorderColor = UIColor(hex: "#2D5A64")
            cell.contentView.customCornerRadius = 10
            cell.contentView.backgroundColor = .white
            cell.imgVehicleBGView.backgroundColor = .white
        } else {
            cell.contentView.customBorderWidth = 0
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9033820629, green: 0.9384498, blue: 0.9333658814, alpha: 1)
            cell.imgVehicleBGView.backgroundColor = #colorLiteral(red: 0.9033820629, green: 0.9384498, blue: 0.9333658814, alpha: 1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KTFareServiceCell") as! KTFareServiceCell
        
        self.setUpfareBreakDownView(fareBreakDownView: cell.fareStackView, cell: cell)
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9033820629, green: 0.9384498, blue: 0.9333658814, alpha: 1)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (self.viewModel as! KTXpressRideCreationViewModel).setPickUpLocationForXpressRide(index: indexPath.row)
    }
    
    @objc func addPickupMarker(sender: UIButton)  {
        
        (self.viewModel as! KTXpressRideCreationViewModel).setPickUpLocationForXpressRide(index: sender.tag)

    }
    
    @objc func orderVehicle(sender: UIButton) {
        
        selectedVehicleIndex = sender.tag
        (self.viewModel as! KTXpressRideCreationViewModel).getRide(index: sender.tag)
        (self.viewModel as! KTXpressRideCreationViewModel).setPickUpLocationForXpressRide(index: sender.tag)
        self.rideServiceTableView.reloadData()
    }
    
    //MARK:- FARE DETAILS BREAKDOWN VIEW
    fileprivate func setUpfareBreakDownView(fareBreakDownView: UIStackView, cell: KTFareServiceCell) {
                
        for i in 0 ..< (vModel?.fareDetailsHeader()?.count ?? 0) {
            setFarDetails(fareDetail: vModel?.fareDetailsHeader()?[i] ?? KTKeyValue(), fareBreakDownView: fareBreakDownView)
        }
        
        for i in 0 ..< 5 {
            setFarDetails(fareDetail: KTKeyValue(), fareBreakDownView: fareBreakDownView)
        }
                        
        fareBreakDownView.backgroundColor = UIColor.clear
        
//        let totalDetailsCount = (vModel?.fareDetailsBody()?.count ?? 0) + 2

    }
    
    fileprivate func setFarDetails(fareDetail: KTKeyValue, fareBreakDownView: UIStackView ) {
        
        guard fareBreakDownView.arrangedSubviews.count < 5 else {
            return
        }
        
        print("Device.language() -> ", Device.language())
        
        let keyLbl = UILabel()
        keyLbl.translatesAutoresizingMaskIntoConstraints = false
        keyLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        keyLbl.text = "Basic pay"//fareDetail.key ?? ""
        keyLbl.textAlignment = .right
        keyLbl.textColor = UIColor(hexString: "#006170")
        keyLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!
        
        let valueLbl = UILabel()
        valueLbl.translatesAutoresizingMaskIntoConstraints = false
        valueLbl.heightAnchor.constraint(equalToConstant: 15).isActive = true
        valueLbl.text = "0.0 QAR"//fareDetail.value ?? ""
        
        if Device.language().contains("ar") {
            valueLbl.textAlignment = .left
            keyLbl.textAlignment = .right
        } else {
            keyLbl.textAlignment = .left
            valueLbl.textAlignment = .right
        }
        
        valueLbl.textColor = UIColor(hexString: "#006170")
        valueLbl.font = UIFont(name: "MuseoSans-500", size: 14.0)!

        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        fareBreakDownView.addArrangedSubview(stackView)
    }
    
    func updateLocationInMap(location: CLLocation) {
        
    }
    
    func updateLocationInMap(location: CLLocation, shouldZoomToDefault withZoom: Bool) {
        
    }
    
}

extension UIStackView {
    
    func removeFully(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func removeFullyAllArrangedSubviews() {
        arrangedSubviews.forEach { (view) in
            removeFully(view: view)
        }
    }
    
}
