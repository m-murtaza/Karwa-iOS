//
//  KTScanAndPayViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

protocol KTPaymentViewModelDelegate : KTViewModelDelegate
{
    func reloadTableData()
    func showPayBtn()
    func showTripPaidScene()
    func showPayNonTappableBtn()
    func showbarcodeScanner(show: Bool)
    func gotoDashboardRequired(required: Bool)
    func gotoManagePayments()
}

class KTPaymentViewModel: KTBaseViewModel
{
    var del : KTPaymentViewModelDelegate?

    var paymentMethods : [KTPaymentMethod] = []
    var selectedPaymentMethod = KTPaymentMethod()

    var sessionId = ""
    var apiVersion = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTPaymentViewModelDelegate
        fetchnPaymentMethods()
        fetchSessionInfo()
    }
    
    func numberOfRows() -> Int
    {
        return paymentMethods.count
    }
    
    func paymentMethodName(forCellIdx idx: Int) -> String
    {
        return "**** **** **** " + paymentMethods[idx].last_four_digits!
    }
    
    func expiry(forCellIdx idx: Int) -> String
    {
        return "EXP. " + paymentMethods[idx].expiry_month! + "/" + paymentMethods[idx].expiry_year!
    }
    
    func cardIcon(forCellIdx idx: Int) -> UIImage
    {
        return UIImage(named: ImageUtil.getImage(paymentMethods[idx].brand!))!
    }
    
    func cardSelection(forCellIdx idx: Int) -> UIImage
    {
        if(paymentMethods[idx].is_selected)
        {
            return UIImage(named: "paymentoption_active_back")!
        }
        else
        {
            return UIImage(named: "paymentoption_inactive_back")!
        }
    }
    
    func paymentTapped()
    {
        self.del?.reloadTableData()
    }
    
    func showingTripPayment()
    {
        let selectedPaymentFromDB = KTPaymentManager().getDefaultPayment()

        if(selectedPaymentFromDB == nil)
        {
            self.del?.showPayNonTappableBtn()
        }
        else
        {
            selectedPaymentMethod = selectedPaymentFromDB!
            self.del?.showPayBtn()
        }
        
    }
    
    func fetchnPaymentMethods()
    {
        paymentMethods = KTPaymentManager().getAllPayments()
        
        let selectedPaymentFromDB = KTPaymentManager().getDefaultPayment()

        if(selectedPaymentFromDB == nil)
        {
            self.del?.showPayNonTappableBtn()
        }
        else
        {
            selectedPaymentMethod = selectedPaymentFromDB!
            self.del?.showPayBtn()
        }

        if paymentMethods.count == 0
        {
            self.del?.showPayNonTappableBtn()
            self.del?.showbarcodeScanner(show: false)
            self.del?.gotoDashboardRequired(required: true)
            self.del?.gotoManagePayments()
        }
        else
        {
            self.del?.gotoDashboardRequired(required: false)
            self.del?.showbarcodeScanner(show: true)
        }
        self.del?.reloadTableData()
    }
    
    func fetchSessionInfo()
    {
        KTPaymentManager().createSessionForPaymentAtServer { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS
            {
                self.sessionId = (response[Constants.PaymentResponseAPIKey.SessionId] as? String)!
                let apiVersionInt : Int = ((response[Constants.PaymentResponseAPIKey.ApiVersion] as? Int)!)
                self.apiVersion = String(apiVersionInt)
            }
        }
    }

    func payTripButtonTapped(payTripBean : PayTripBeanForServer)
    {
        self.del?.showProgressHud(show: true, status: "We are paying your amount")
        
        let message = selectedPaymentMethod.source!

        KTPaymentManager().payTripAtServer(AESEncryption.init().encrypt(message), payTripBean.data) { (success, response) in

            self.del?.hideProgressHud()

            if success == Constants.APIResponseStatus.SUCCESS
            {
                AnalyticsUtil.trackCardPayment(payTripBean.totalFare)

                self.del?.showTripPaidScene()

                self.del?.showSuccessBanner("  ", "Trip amount has been paid successfully")
            }
            else
            {
                self.del?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
    
    func updatePaymentMethod()
    {
        AnalyticsUtil.trackAddPaymentMethod("")
        self.del?.showProgressHud(show: true, status: "Updating payment methods")
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.del?.hideProgressHud()
            self.del?.showSuccessBanner("  ", "Payment method added successfully")
            self.fetchnPaymentMethods()
        }
    }
    
    func updateEmail(email: String)
    {
        let user = loginUserInfo()
        updateProfile(userName: "", userEmail: email, dob: nil, gen: user.gender, shouldValidate: true)
    }
    
    func loginUserInfo() -> KTUser {
        return KTUserManager().loginUserInfo()!
    }
    
    func rowSelected(atIndex idx: Int)
    {
        selectedPaymentMethod = paymentMethods[idx]
        KTPaymentManager().makeDefaultPaymentMethod(defaultPaymentMethod: selectedPaymentMethod)
        self.del?.reloadTableData()
    }
    
    func getRefinedYear(_ year:UInt) ->String
    {
        var refinedYear = String(year)
        if(refinedYear.count > 2)
        {
            refinedYear = String(refinedYear.suffix(2))
        }
        return refinedYear
    }
    
    func getRefinedMonth(_ month:UInt) ->String
    {
        var refinedMonth = String(month)
        if(refinedMonth.count < 2)
        {
            refinedMonth = "0" + refinedMonth
        }
        return refinedMonth
    }
    
    func updateProfile(userName : String?, userEmail : String?, dob: Date?, gen: Int16, shouldValidate: Bool)
    {
        var error = ""
        if(shouldValidate)
        {
            error = validate(userName: userName, userEmail: userEmail)
        }
        
        if  error.isEmpty
        {
            delegate?.showProgressHud(show: true, status: "Updating Account Info")
            
            KTUserManager().updateUserInfo(
                name: userName!,
                email: (userEmail != nil && !userEmail!.isEmpty) ? userEmail! : "",
                dob: dob?.getServerFormatDate() ?? "",
                gender: gen,
                completion: { (status, response) in

                    self.delegate?.hideProgressHud()

                    if status == Constants.APIResponseStatus.SUCCESS
                    {
                        self.delegate?.showPopupMessage("", "Email added successfully, Please verify")
                    }
                    else
                    {
                        self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                    }
            })
        }
        else {
            self.delegate?.showError!(title: "Error" , message: error)
        }
    }
    
    func validate(userName : String?, userEmail : String?) -> String {
        var errorString :String = ""
        if userEmail == nil || userEmail == "" || userEmail?.isEmail == false {
            errorString = "Please enter valid email address"
        }
        return errorString
    }
}
