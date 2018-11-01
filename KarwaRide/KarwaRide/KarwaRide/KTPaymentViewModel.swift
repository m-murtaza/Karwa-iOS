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
        return UIImage(named: getImage(paymentMethods[idx].brand!))!
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
    
    func fetchnPaymentMethods()
    {
        paymentMethods = KTPaymentManager().getAllPayments()
        
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
        self.del?.showProgressHud(show: true, status: "Verifying card information")

        if(sessionId.count == 0 || apiVersion.count == 0)
        {
            self.del?.hideProgressHud()
            self.del?.showErrorBanner("", "Payment Verification is not available, please try again later")
            fetchSessionInfo()
        }
        else
        {
            // MARK: - Gateway Setup
            let gateway: Gateway = Gateway(region: GatewayRegion.mtf, merchantId: "TESTMOWKAREVL01")
            
            var request = GatewayMap()
            request[at: "sourceOfFunds.provided.card.nameOnCard"] = cardHolderName
            request[at: "sourceOfFunds.provided.card.number"] = cardNo
            request[at: "sourceOfFunds.provided.card.securityCode"] = ccv
            request[at: "sourceOfFunds.provided.card.expiry.month"] = getRefinedMonth(month)
            request[at: "sourceOfFunds.provided.card.expiry.year"] = getRefinedYear(year)
            
            gateway.updateSession(sessionId, apiVersion: self.apiVersion, payload: request, completion: updateSessionHandler(_:))
        }
    }
    
    // MARK: - Handle the Update Response
    // Call the gateway to update the session.
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

                var message = "Unable to update session."
                if case GatewayError.failedRequest( _, let explination) = error
                {
                    message = explination
                }
                
                self.del?.showErrorBanner("Error", message)

                break;
        }
    }
    
    func updateCardToServer()
    {
        KTPaymentManager().updateMPGSSuccessAtServer(sessionId, apiVersion, completion: { (status, response) in
            
            self.del?.hideProgressHud()
            self.del?.showProgressHud(show: true, status: "Syncing payment methods")
            
            if status == Constants.APIResponseStatus.SUCCESS
            {
                self.del?.hideCardIOPaymentController()

                self.del?.showSuccessBanner("Payment Method Added", "Payment method has been added successfully")
                
                KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            
                    self.del?.hideProgressHud()
                    self.fetchnPaymentMethods()
                }
            }
            else
            {
                self.del?.showError!(title: response["T"] as! String, message: response["M"] as! String)
            }
        })
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
    
    func getImage(_ brand: String) -> String
    {
        var brandImage = "ico_wallet"
        
        switch brand
        {
        case "MASTERCARD":
            brandImage = "ico_mc"
            break;
        case "MASTER":
            brandImage = "ico_mc"
            break;
        case "VISACARD":
            brandImage = "ico_visa"
            break;
        case "VISA":
            brandImage = "ico_visa"
            break;
        case "AMEXCARD":
            brandImage = "ico_amex"
            break;
        case "AMEX":
            brandImage = "ico_amex"
            break;
        case "DINERSCLUBCARD":
            brandImage = "ico_dinersclub"
            break;
        case "DINERS_CLUB":
            brandImage = "ico_dinersclub"
            break;
        case "DISCOVERCARD":
            brandImage = "ico_discover"
            break;
        case "DISCOVER":
            brandImage = "ico_discover"
            break;
        case "JCBCARD":
            brandImage = "ico_jcb"
            break;
        case "JCB":
            brandImage = "ico_jcb"
            break;
        case "MAESTROCARD":
            brandImage = "ico_maestro"
            break;
        case "MAESTRO":
            brandImage = "ico_maestro"
            break;
        default:
            brandImage = "ico_wallet"
            break;
        }
        return brandImage
    }
}

