//
//  KTScanAndPayViewModel.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/29/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation
import PassKit

protocol KTPaymentViewModelDelegate : KTViewModelDelegate
{
    func reloadTableData()
    func showPayBtn()
    func showTripPaidScene()
    func showPayNonTappableBtn()
    func showbarcodeScanner(show: Bool)
    func gotoDashboardRequired(required: Bool)
    func gotoManagePayments()
    func removeAllTags()
    func addTag(tag: String)
    func tagViewTapped()
    func selectedTipIdx() -> [NSNumber]
    func getPayTripBean() -> PayTripBeanForServer
    func updatePayButton(btnText value: String)
}

class KTPaymentViewModel: KTBaseViewModel
{
    var del : KTPaymentViewModelDelegate?

    var paymentMethods : [KTPaymentMethod] = []
    var selectedPaymentMethod = KTPaymentMethod()

    var sessionId = ""
    var apiVersion = ""
    
    var transaction: Transaction?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTPaymentViewModelDelegate
        
        del?.removeAllTags()

        for tipOption in Constants.TIP_OPTIONS
        {
            del?.addTag(tag: tipOption)
        }

        transaction = Transaction()
    }
    
    override func viewWillAppear() {
        fetchnPaymentMethods()
    }
    
    func getPaymentData() {
        
        self.del?.showProgressHud(show: true)
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.del?.hideProgressHud()
            self.fetchnPaymentMethods()
        }
    }

    func payTripButtonTapped(payTripBean : PayTripBeanForServer)
    {
        self.del?.showProgressHud(show: true, status: "str_paying_with_card".localized())

        let message = selectedPaymentMethod.source!

        payTripToServer(payTripBean: payTripBean, source: AESEncryption.init().encrypt(message))
    }
    
    func processApplePaymentToken(payment: PKPayment)
    {
        let paymentToken = String(data: payment.token.paymentData, encoding: .utf8)!
        
        self.del?.showProgressHud(show: true, status: "str_paying_with_card".localized())

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.payTripToServerWithApplePay(payTripBean: (self.del?.getPayTripBean())!, paymentToken: paymentToken)
        }
    }

    func payTripToServer(payTripBean : PayTripBeanForServer, source : String)
    {
        KTPaymentManager().payTripAtServer(source, payTripBean.data, selectedTipValue()) { (success, response) in

            self.del?.hideProgressHud()

            if success == Constants.APIResponseStatus.SUCCESS
            {
                AnalyticsUtil.trackCardPayment(payTripBean.totalFare)

                self.del?.showTripPaidScene()

                self.del?.showSuccessBanner("  ", "txt_paid_success".localized())
            }
            else
            {
                self.del?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
    
    func payTripToServerWithApplePay(payTripBean : PayTripBeanForServer, paymentToken : String)
    {
        KTPaymentManager().payTripAtServerWithApplePay(paymentToken, payTripBean.data, selectedTipValue()) { (success, response) in

            self.del?.hideProgressHud()

            if success == Constants.APIResponseStatus.SUCCESS
            {
                AnalyticsUtil.trackCardPayment(payTripBean.totalFare)

                self.del?.showTripPaidScene()

                self.del?.showSuccessBanner("  ", "txt_paid_success".localized())
            }
            else
            {
                self.del?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        }
    }
    
    func updateTotalAmountInApplePay(payTripBeanForServer: PayTripBeanForServer)
    {
        let totalAmount = Int(payTripBeanForServer.totalFare)! + Int(selectedTipValue())!

        let totalFareWithTip = NSDecimalNumber(value: totalAmount)
        transaction?.amount = totalFareWithTip
        transaction?.amountString = totalFareWithTip.stringValue
        transaction?.amountFormatted = String("str_qr".localized() + totalFareWithTip.stringValue)
    }
    
    func numberOfRows() -> Int
    {
        return paymentMethods.count
    }
    
    func paymentMethodName(forCellIdx idx: Int) -> String
    {
        
        if paymentMethods[idx].payment_type == "WALLET" {
            return "str_wallet".localized()
        } else {
            return "**** **** **** " + paymentMethods[idx].last_four_digits!
        }
        
    }
    
    func expiry(forCellIdx idx: Int) -> String
    {
        
        if paymentMethods[idx].payment_type == "WALLET" {
            return "str_balance".localized() + " " + (paymentMethods[idx].balance ?? "")
        } else {
            return "EXP. " + paymentMethods[idx].expiry_month! + "/" + paymentMethods[idx].expiry_year!
        }
        
    }
    
    func cardIcon(forCellIdx idx: Int) -> UIImage
    {
        if paymentMethods[idx].payment_type == "WALLET" {
            return UIImage(named: ImageUtil.getImage(paymentMethods[idx].payment_type!))!
        } else {
            return UIImage(named: ImageUtil.getImage(paymentMethods[idx].brand!))!
        }
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
    
    func selectedTipValue() -> String
    {
        var selectedTipValue = "0"
        for r in (del?.selectedTipIdx())!
        {
            selectedTipValue = Constants.TIP_OPTIONS_VALUES[r.intValue]
        }

        return selectedTipValue
    }

    func tagViewTapped()
    {
        let fareWithTip = Int(((del?.getPayTripBean().totalFare)!))! + Int(selectedTipValue())!
        del?.updatePayButton(btnText: String(fareWithTip))
        updateTotalAmountInApplePay(payTripBeanForServer: (del?.getPayTripBean())!)
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

    func isPaymentMethodAdded() -> Bool
    {
        return KTPaymentManager().getDefaultPayment() != nil
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

        if paymentMethods.count == 0 && !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: (Transaction().supportedNetworks))
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

    func tipOptions(atIndex idx: Int) -> String {
        return Constants.TIP_OPTIONS[idx]
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
            delegate?.showProgressHud(show: true, status: "profile_updated".localized())
            
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
