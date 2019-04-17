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
    func showEmptyScreen()
    func hideEmptyScreen()
    func hideCardIOPaymentController()
    func deleteRowWithAnimation(_ index: IndexPath)
    func showPayBtn()
    func showTripPaidScene()
    func showPayNonTappableBtn()
    func show3dSecureController(_ html: String)
    func showbarcodeScanner(show: Bool)
    func gotoDashboardRequired(required: Bool)
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
    
    func deletePaymentMethod(_ indexPath: IndexPath)
    {
        self.del?.showProgressHud(show: true, status: "Removing Payment Method")
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
                    self.del?.showPayNonTappableBtn()
                }
                
                self.del?.showSuccessBanner("  ", "Payment method removed successfully")
                
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
                self.del?.showErrorBanner(response["T"] as! String, response["M"] as! String)
            }
        }
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
            self.del?.showEmptyScreen()
            self.del?.showPayNonTappableBtn()
            self.del?.showbarcodeScanner(show: false)
            self.del?.gotoDashboardRequired(required: true)
        }
        else
        {
            self.del?.gotoDashboardRequired(required: false)
            self.del?.showbarcodeScanner(show: true)
            self.del?.hideEmptyScreen()
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
    
    // Call the gateway to update the session.
    func updateSession(_ cardHolderName:String, _ cardNo:String, _ ccv:String, _ month:UInt, _ year:UInt)
    {
        self.del?.showProgressHud(show: true, status: "Verifying card information")

        if(sessionId.count == 0 || apiVersion.count == 0)
        {
            self.del?.hideProgressHud()
            self.del?.showErrorBanner("Sorry", "Payment verification is not available, try again later")
            fetchSessionInfo()
        }
        else
        {
            // MARK: - Gateway Setup

            let gateway: Gateway = Gateway(region: GatewayRegion.mtf, merchantId: Constants.MERCHANT_ID)

            var request = GatewayMap()
            request[at: "sourceOfFunds.provided.card.nameOnCard"] = cardHolderName
            request[at: "sourceOfFunds.provided.card.number"] = cardNo
            request[at: "sourceOfFunds.provided.card.securityCode"] = ccv
            request[at: "sourceOfFunds.provided.card.expiry.month"] = getRefinedMonth(month)
            request[at: "sourceOfFunds.provided.card.expiry.year"] = getRefinedYear(year)
            
            gateway.updateSession(sessionId, apiVersion: self.apiVersion, payload: request, completion: updateSessionHandler(_:))
        }
    }
    
    // MARK: - Handle the Update Response call the gateway to update the session
    fileprivate func updateSessionHandler(_ result: GatewayResult<GatewayMap>)
    {
        self.del?.hideProgressHud()

        switch result
        {
            case .success(_):
                self.del?.showProgressHud(show: true, status: "Adding card payment to your account")
                updateCardToServer()
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
                    self.del?.show3dSecureController(html!)
                }
                else
                {
                    self.updatePaymentMethod()
                }
            }
            else
            {
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
        self.del?.showProgressHud(show: true, status: "Updating payment methods")
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.del?.hideProgressHud()
            self.del?.showSuccessBanner("  ", "Payment method added successfully")
            self.fetchnPaymentMethods()
        }
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
}
