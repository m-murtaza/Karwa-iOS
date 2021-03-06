//
//  KTManagePaymentViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/28/19.
//  Copyright © 2019 Karwa. All rights reserved.
//

import Foundation

protocol KTManagePaymentViewModelDelegate : KTViewModelDelegate
{
    func reloadTableData()
    func showEmptyScreen()
    func hideEmptyScreen()
    func showAddCardVC()
    func showVerifyEmailPopup(email: String)
    func showEnterEmailPopup()
    func hideCardIOPaymentController()
    func deleteRowWithAnimation(_ index: IndexPath)
    func show3dSecureController(_ html: String)
}

extension KTManagePaymentViewModelDelegate {
    func showEmptyScreen() {}
    func hideEmptyScreen() {}
    func showAddCardVC() {}
    func showVerifyEmailPopup(email: String) {}
    func showEnterEmailPopup() {}
    func deleteRowWithAnimation(_ index: IndexPath){}
    func hideCardIOPaymentController() {}
    func show3dSecureController(_ html: String) {}
    
}

class KTManagePaymentViewModel: KTBaseViewModel
{
    var del : KTManagePaymentViewModelDelegate?
    
    var paymentMethods : [KTPaymentMethod] = []
    var selectedPaymentMethod = KTPaymentMethod()
    
    var sessionId = ""
    var apiVersion = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTManagePaymentViewModelDelegate
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
    
    func deletePaymentMethod(_ indexPath: IndexPath)
    {
        self.del?.showProgressHud(show: true, status: "please_dialog_msg_delete_payment".localized())
        let paymentManager = KTPaymentManager()
        
        let deletionMethod = paymentMethods[indexPath.row]
        let source = AESEncryption.init().encrypt(deletionMethod.source!)
        
        paymentManager.deletePaymentAtServer(paymentMethod: source) { (status, response) in
            
            self.del?.hideProgressHud()
            
            if(status == Constants.APIResponseStatus.SUCCESS)
            {
                AnalyticsUtil.trackRemovePaymentMethod(deletionMethod.brand ?? "")
                
                paymentManager.deletePaymentMethods(deletionMethod)
                
                self.paymentMethods.remove(at: indexPath.row)
                self.del?.deleteRowWithAnimation(indexPath)
                
                if(self.paymentMethods.count == 0)
                {
                    self.del?.showEmptyScreen()
                }
                
                self.del?.showSuccessBanner("  ", "txt_payment_method_removed".localized())
                
                if(self.paymentMethods.count > 0 && paymentManager.getDefaultPayment() == nil)
                {
                    let newListWithDefaultSelection = paymentManager.makeOnePaymentMethodDefaultAndReturn()
                    self.selectedPaymentMethod = newListWithDefaultSelection[0]
                    self.paymentMethods.removeAll()
                    self.paymentMethods = newListWithDefaultSelection
                    self.del?.reloadTableData()
                }
            }
            else
            {
                let title = response["T"] != nil ? response["T"] as! String : "error_sr".localized()
                let message = response["M"] != nil ? response["M"] as! String : "please_dialog_msg_went_wrong".localized()
                self.del?.showErrorBanner(title, message)
            }
        }
    }
    
    func paymentMethodsCount() -> Int
    {
        return self.paymentMethods.count
    }
    
    func showingTripPayment()
    {
        let selectedPaymentFromDB = KTPaymentManager().getDefaultPayment()
        
        if(selectedPaymentFromDB != nil)
        {
            selectedPaymentMethod = selectedPaymentFromDB!
        }
    }
    
    func fetchnPaymentMethods()
    {
        paymentMethods = KTPaymentManager().getAllPayments()
        
        paymentMethods = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})
        
        if paymentMethods.count != 0 {
            
            let selectedPaymentFromDB = KTPaymentManager().getDefaultPayment()
            
            if(selectedPaymentFromDB != nil)
            {
                selectedPaymentMethod = selectedPaymentFromDB!
            }

            if paymentMethods.count == 0
            {
                self.del?.showEmptyScreen()
            }
            else
            {
                self.del?.hideEmptyScreen()
            }

            self.del?.reloadTableData()
        }
        
       
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
    
    // Call the gateway to update the session.
    func updateSession(_ cardHolderName:String, _ cardNo:String, _ ccv:String, _ month:UInt, _ year:UInt)
    {
        self.del?.showProgressHud(show: true, status: "verifying_card_information".localized())
        
        if(sessionId.count == 0 || apiVersion.count == 0)
        {
            self.del?.hideProgressHud()
            self.del?.showErrorBanner("error_sr".localized(), "txt_not_available".localized())
            fetchSessionInfo()
        }
        else
        {
            // MARK: - Gateway Setup
            
            let gateway: Gateway = Gateway(region: Constants.GATEWAY_REGION, merchantId: Constants.MERCHANT_ID)
            
            var request = GatewayMap()
            request[at: "sourceOfFunds.provided.card.nameOnCard"] = cardHolderName
            request[at: "sourceOfFunds.provided.card.number"] = cardNo
            request[at: "sourceOfFunds.provided.card.securityCode"] = ccv
            request[at: "sourceOfFunds.provided.card.expiry.month"] = getRefinedMonth(month)
            request[at: "sourceOfFunds.provided.card.expiry.year"] = getRefinedYear(year)
            
            gateway.updateSession(sessionId, apiVersion: self.apiVersion, payload: request, completion: updateSessionHandler(_:))

            
//            gateway.updateSession(sessionId, apiVersion: self.apiVersion, payload: request, completion: updateSessionHandler(_:))
        }
    }
    
    // MARK: - Handle the Update Response call the gateway to update the session
    fileprivate func updateSessionHandler(_ result: GatewayResult<GatewayMap>)
    {
                    
            self.del?.hideProgressHud()
            
            switch result
            {
            case .success(_):
                self.del?.showProgressHud(show: true, status: "adding_card_payment_str".localized())
                self.updateCardToServer()
                break;
                
            case .error(let error):
                self.del?.hideCardIOPaymentController()
                
                var message = "Unable to update session."
                if case GatewayError.failedRequest( _, let explination) = error
                {
                    message = explination
                }
                
                DispatchQueue.main.async {
                    self.del?.showErrorBanner("   ", message)
                }
                
                break;
            }
        
        
        
    }
    
    func updateCardToServer()
    {
        KTPaymentManager().updateMPGSSuccessAtServer(sessionId, apiVersion, completion: { (status, response) in
            
            self.del?.hideProgressHud()
            self.del?.hideCardIOPaymentController()

            if status == Constants.APIResponseStatus.SUCCESS
            {
                let html = response["Html"] as? String
                if(html != nil)
                {
                    DispatchQueue.main.async {
                        self.del?.show3dSecureController(html!)
                    }
                }
                else
                {
                    DispatchQueue.main.async {
                        self.updatePaymentMethod()
                    }
                }
            }
            else
            {
                self.del?.hideCardIOPaymentController()
                self.del?.showErrorBanner("   ", response["M"] as! String)
            }
        })
    }
    
    func kmpgs3dSecureFailure(_ result: String)
    {
        self.del?.showErrorBanner("   ", result)
    }
    
    func updatePaymentMethod()
    {
        AnalyticsUtil.trackAddPaymentMethod("")
        self.del?.showProgressHud(show: true, status: "dialog_msg_updating_profile".localized())
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.del?.hideProgressHud()
            self.del?.showSuccessBanner("  ", "profile_updated".localized())
            self.fetchnPaymentMethods()
        }
    }
    
    func addCardButtonTapped()
    {
        let user = loginUserInfo()
        if user.email != nil && !(user.email!.isEmpty)
        {
            if(user.isEmailVerified)
            {
                self.del?.showAddCardVC()
            }
            else
            {
                self.del?.showVerifyEmailPopup(email: user.email ?? "")
            }
        }
        else
        {
            self.del?.showEnterEmailPopup()
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
            delegate?.showProgressHud(show: true, status: "dialog_msg_updating_profile".localized())
            
            KTUserManager().updateUserInfo(
                name: userName!,
                email: (userEmail != nil && !userEmail!.isEmpty) ? userEmail! : "",
                dob: dob?.getServerFormatDate() ?? "",
                gender: gen,
                completion: { (status, response) in
                    
                    self.delegate?.hideProgressHud()
                    
                    if status == Constants.APIResponseStatus.SUCCESS
                    {
                        self.delegate?.showPopupMessage("", "profile_updated".localized())
                    }
                    else
                    {
                        self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
                    }
            })
        }
        else {
            self.delegate?.showError!(title: "error_sr".localized() , message: error)
        }
    }
    
    func validate(userName : String?, userEmail : String?) -> String {
        var errorString :String = ""
        if userEmail == nil || userEmail == "" || userEmail?.isEmail == false {
            errorString = "err_enter_valid_email".localized()
        }
        return errorString
    }
}

