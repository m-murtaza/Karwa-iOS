//
//  KTMasedEmailConfirmationViewModel.swift
//  KarwaRide
//
//  Created by Irfan Muhammed on 5/20/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation
import CoreLocation

protocol KTMaskedEmailViewModelDelegate: KTViewModelDelegate {

    func phoneNumber() -> String?
    func email() -> String?
    func md5password() -> String?
    func countryCallingCode() -> String?
    func getChallenge() -> String?
    func getChallengeType() -> String?
    func getChallengeAnswer() -> String?
    func navigateToLogin()
    func showAlertForLocationServerOn()
    func setLocation(name: String)
}

class KTMasedEmailConfirmationViewModel: KTBaseViewModel {
 
    var email: String = ""
    static var askedToTurnOnLocaiton : Bool = false

    func setupCurrentLocaiton() {
        if KTLocationManager.sharedInstance.locationIsOn() {
            if KTLocationManager.sharedInstance.isLocationAvailable {
                var notification : Notification = Notification(name: Notification.Name(rawValue: Constants.Notification.LocationManager))
                var userInfo : [String :Any] = [:]
                userInfo["location"] = KTLocationManager.sharedInstance.baseLocation
                
                notification.userInfo = userInfo
                LocationManagerLocaitonUpdate(notification: notification)
            }
            else {
                KTLocationManager.sharedInstance.start()
            }
        }
        else if KTCreateBookingViewModel.askedToTurnOnLocaiton == false {
            (delegate as! KTMaskedEmailViewModelDelegate).showAlertForLocationServerOn()
        }
    }
    
    @objc func LocationManagerLocaitonUpdate(notification: Notification) {
        let location : CLLocation = notification.userInfo!["location"] as! CLLocation
        self.fetchLocationName(forGeoCoordinate: location.coordinate)
    }
    
    func fetchLocationName(forGeoCoordinate coordinate: CLLocationCoordinate2D) {
        KTBookingManager().address(forLocation: coordinate, Limit: 1) { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS && response[Constants.ResponseAPIKey.Data] != nil && (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation]).count > 0{
                let pAddress : KTGeoLocation = (response[Constants.ResponseAPIKey.Data] as! [KTGeoLocation])[0]
                DispatchQueue.main.async {
                    //self.delegate?.userIntraction(enable: true)
                    if self.delegate != nil {
                        (self.delegate as! KTMaskedEmailViewModelDelegate).setLocation(name: pAddress.name ?? "")
                    }
                }
            }
        }
    }

    
    func verifyChallenge()
    {
        let phone = (delegate as! KTMaskedEmailViewModelDelegate).phoneNumber() ?? ""
        let countryCode = (delegate as! KTMaskedEmailViewModelDelegate).countryCallingCode() ?? ""
        let challenge = (delegate as! KTMaskedEmailViewModelDelegate).getChallenge() ?? ""
        let challengeType = (delegate as! KTMaskedEmailViewModelDelegate).getChallengeType() ?? ""
        let challengeAnswer = (delegate as! KTMaskedEmailViewModelDelegate).getChallengeAnswer() ?? ""
        
        let error = validate(type: challengeType)
        if error.count == 0
        {
          delegate?.showProgressHud(show: true, status: "str_verify_challenge".localized())
            
            KTUserManager().verifyChallenge(countryCode: countryCode, phone: phone, challenge: challenge, challengeType: challengeType, challengeAnswer: challengeAnswer) { (status, response) in
                self.delegate?.hideProgressHud()
                if status == Constants.APIResponseStatus.SUCCESS {
                    (self.delegate as! KTMaskedEmailViewModelDelegate).navigateToLogin()
                } else {
                    (self.delegate as! KTMaskedEmailViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                                  message: response["M"] as! String)
                }
            }
            
        }
        else
        {
          (delegate as! KTMaskedEmailViewModelDelegate).showError!(title: "error_sr".localized(),
                                                                   message: error)
        }
        
    }
    
    func validate(type: String) -> String {
        var errorString : String = ""
        if type == "Email" {
            if email == "" || email.isEmail == false {
                errorString = "err_no_email".localized()
            }
        }
        return errorString
    }
}
