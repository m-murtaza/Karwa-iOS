//
//  KTMaskedEmailConfirmationVC.swift
//  KarwaRide
//
//  Created by SAM on 5/20/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation
import Spring
import MaterialComponents
import GoogleMaps
import UIKit

class KTMaskedEmailConfirmationVC: KTBaseViewController, KTMaskedEmailViewModelDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var titleText: SpringLabel!
    @IBOutlet weak var lblMaskedEmail: SpringLabel!
    @IBOutlet weak var emailTextField: MDCFilledTextField!
    @IBOutlet weak var emailTextFieldBGView: UIView!
    @IBOutlet weak var mapView : GMSMapView!
    @IBOutlet weak var mapBGView : UIView!

    var phone : String = ""
    var password: String = ""
    var maskedEmail: String = ""
    var countryCode: String = ""
    var previousView : KTBaseLoginSignUpViewController?
    var challengeType = ""
    var latitude = ""
    var longitude = ""

    
    //MARK: -View LifeCycle
    override func viewDidLoad() {
        viewModel = KTMasedEmailConfirmationViewModel(del:self)
        super.viewDidLoad()
        lblMaskedEmail.text = maskedEmail
        emailTextField.delegate = self
        InputFieldUtil.applyTheme(emailTextField, false)
        tapToDismissKeyboard()
        emailTextFieldBGView.clipsToBounds = true
        emailTextFieldBGView.customBorderWidth = 0
        mapView.delegate = self
        if challengeType == "Name" {
            self.titleText.text = "str_complete_name".localized()
            emailTextField.label.text = "str_name".localized()
            self.mapView.isHidden = true
        } else if challengeType == "Email" {
            self.titleText.text = "str_complete_email".localized()
            emailTextField.label.text = "str_email".localized()
            self.mapView.isHidden = true
        }
        else {
            self.titleText.text = "str_select_place".localized()
            self.mapView.isHidden = false
            self.addMap()
            (self.viewModel as! KTMasedEmailConfirmationViewModel).setupCurrentLocaiton()
        }
        
       
        // Do any additional setup after loading the view.
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnSubmitTapped))
    }
    
    func setLocation(name: String) {
        self.lblMaskedEmail.text = name
    }
    
    func showAlertForLocationServerOn() {
        let alertController = UIAlertController(title: "",
                                                message: "str_enable_location_services".localized(),
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (UIAlertAction) in
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SegueMaskedEmailToOTP"
        {
            let otpView : KTOTPViewController = segue.destination as! KTOTPViewController
            otpView.previousView = previousView
            otpView.countryCode = countryCode
            otpView.phone = phoneNumber()!
            otpView.otpType = "RESET_PASSWORD_CHALLENGE"
            otpView.password = self.password
        }
    }
    
    @IBAction func btnSubmitTapped(_ sender: Any)
    {
        (viewModel as! KTMasedEmailConfirmationViewModel).verifyChallenge()
    }
    
    func countryCallingCode() -> String? {
        return countryCode
    }
    
    func phoneNumber() -> String? {
        return phone
    }
    
    func getChallenge() -> String? {
        return maskedEmail
    }
    
    func getChallengeType() -> String? {
        return challengeType
    }
    
    func getChallengeAnswer() -> String? {
        if self.challengeType == "Name" || self.challengeType == "Email" {
            return self.emailTextField.text ?? ""
        } else {
            return self.latitude+","+self.longitude
        }
    }
    
    func email() -> String? {
        return emailTextField.text
    }
    
    func md5password() -> String? {
        return password
    }
    
    func navigateToLogin() {
        let alertController = UIAlertController(title: "",
                                                message: "str_verified".localized(),
                                                preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("OK".localized(), comment: ""), style: .default) { (UIAlertAction) in
            if self.previousView != nil {
                self.previousView?.dismiss()
            }
        }
        alertController.addAction(doneAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnCloseTapped(_ sender: Any) {
        if previousView != nil {
            previousView?.dismiss()
        }
    }
    
    internal func showCurrentLocationDot(show: Bool) {
        self.mapView!.isMyLocationEnabled = show
    }
    
    internal func addMap() {

        let camera = GMSCameraPosition.camera(withLatitude: 25.281308, longitude: 51.531917, zoom: 14.0)
        
        showCurrentLocationDot(show: true)
        self.mapView.camera = camera;
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        mapView.padding = padding
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "map_style_karwa", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
      
      mapView.delegate = self
    
      self.focusMapToCurrentLocation()
    }
    
    func focusMapToCurrentLocation()
    {
        if(KTLocationManager.sharedInstance.isLocationAvailable && KTLocationManager.sharedInstance.currentLocation.coordinate.isZeroCoordinate == false)
        {
            let update :GMSCameraUpdate = GMSCameraUpdate.setTarget(KTLocationManager.sharedInstance.currentLocation.coordinate, zoom: KTCreateBookingConstants.DEFAULT_MAP_ZOOM)
            mapView.animate(with: update)
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print(mapView.camera.target.latitude)
        print(mapView.camera.target.longitude)
        latitude = "\(mapView.camera.target.latitude)"
        longitude = "\(mapView.camera.target.longitude)"
        
        self.lblMaskedEmail.text = latitude + "," + longitude
        (self.viewModel as! KTMasedEmailConfirmationViewModel).fetchLocationName(forGeoCoordinate: CLLocationCoordinate2D(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude))
    }
    
    
    
}

extension KTMaskedEmailConfirmationVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emailTextFieldBGView.customBorderWidth = 3
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        emailTextFieldBGView.customBorderWidth = 0
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextFieldBGView.customBorderWidth = 0
    }
}

