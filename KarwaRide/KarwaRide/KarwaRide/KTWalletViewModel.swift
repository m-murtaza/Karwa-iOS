//
//  KTWalletViewModel.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 05/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

protocol KTWalletViewModelDelegate: KTManagePaymentViewModelDelegate {
    func reloadTableData()
    func loadAvailableBalance(_ amount: String)
    func showCyberSecureViewController(url: String)
    func closeView()
    func moveToAddCredit()
}

extension KTWalletViewModelDelegate {
    func loadAvailableBalance(_ amount: String) {}
    func showCyberSecureViewController(url: String) {}
    func moveToAddCredit() {}
}

class KTWalletViewModel: KTBaseViewModel {
    
    var del : KTManagePaymentViewModelDelegate?
    var transactionDelegate : KTWalletViewModelDelegate?

    var paymentMethods : [KTPaymentMethod] = []
    var selectedPaymentMethod = KTPaymentMethod()
    var transactions : [KTTransactions] = []
    var debitCardSelected = false
    
    var paymentSelected = false


    //AESEncryption.init().encrypt(message)
    var sessionId = ""
    var apiVersion = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTManagePaymentViewModelDelegate
        transactionDelegate = self.delegate as? KTWalletViewModelDelegate
        
//        KTUserManager.init().isUserLogin { (login:Bool) in
//            if login == true
//            {
//                self.transactionDelegate?.showProgressHud(show: true, status: "str_loading".localized())
//                self.fetchTransactionsServer()
//            }
//            else
//            {
//                (UIApplication.shared.delegate as! AppDelegate).showLogin()
//            }
//        }
//
//
//        self.fetchnPaymentMethods()
//        self.fetchSessionInfo()
        
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    func fetchLatestTransactions() {
        KTUserManager.init().isUserLogin { (login:Bool) in
            if login == true
            {
                self.transactionDelegate?.showProgressHud(show: true, status: "str_loading".localized())
                self.fetchTransactionsServer()
            }
            else
            {
                (UIApplication.shared.delegate as! AppDelegate).showLogin()
            }
        }
        
        self.fetchSessionInfo()
    }
  
    func numberOfCardRows() -> Int {
        return paymentMethods.count
       // return paymentMethods.count == 0 ? 1 : paymentMethods.count
    }
    
    func paymentMethodName(forCellIdx idx: Int) -> String {
                
        if paymentMethods[idx].balance != nil && paymentMethods[idx].balance != ""{
            return paymentMethods[idx].payment_type!
        } else {
            return "**** **** **** " + (paymentMethods[idx].last_four_digits ?? "")
        }
        
    }
    
    func expiry(forCellIdx idx: Int) -> String {
        
        guard paymentMethods[idx] != nil else {
            return ""
        }
        
        if paymentMethods[idx].balance != nil && paymentMethods[idx].balance != ""{
            return ""
        } else {
            return "EXP. " + paymentMethods[idx].expiry_month! + "/" + paymentMethods[idx].expiry_year!
        }
    }
    
    func moveToAddCredit() {
        if  paymentMethods.count  == 0 {
            self.transactionDelegate?.showError?(title: "str_addcredit_first".localized(), message: "")
        } else {
            self.transactionDelegate?.moveToAddCredit()
        }
    }
    
    func cardIcon(forCellIdx idx: Int) -> UIImage {
        if paymentMethods[idx].balance != nil && paymentMethods[idx].balance != ""{
            return UIImage(named: ImageUtil.getTransactionImage("PAIDWALLET"))!
        } else {
            return UIImage(named: ImageUtil.getImage(paymentMethods[idx].brand!))!
        }
    }
    
    func cardSelection(forCellIdx idx: Int) -> UIColor {
        if(paymentMethods[idx].is_selected) {
            return UIColor(hexString: "#00A8A8")
        }
        else {
            return UIColor(hexString: "#EBEBEB")
        }
    }
    
    func cardSelectionStatusIcon(forCellIdx idx: Int) -> UIImage {
        if(paymentMethods[idx].is_selected) {
            return #imageLiteral(resourceName: "checked_icon")
        } else {
            return #imageLiteral(resourceName: "uncheck_icon")
        }
    }
        
    func paymentTapped() {
        self.transactionDelegate?.reloadTableData()
    }
    
    func deletePaymentMethod(_ indexPath: IndexPath)
    {
        self.transactionDelegate?.showProgressHud(show: true, status: "please_dialog_msg_delete_payment".localized())
        let paymentManager = KTWalletManager()
        
        let deletionMethod = paymentMethods[indexPath.row]
        let source = AESEncryption.init().encrypt(deletionMethod.source!)
        
        paymentManager.deletePaymentAtServer(paymentMethod: source) { (status, response) in
            
            self.transactionDelegate?.hideProgressHud()
            
            if(status == Constants.APIResponseStatus.SUCCESS)
            {
                AnalyticsUtil.trackRemovePaymentMethod(deletionMethod.brand ?? "")
                
                paymentManager.deletePaymentMethods(deletionMethod)

                self.fetchnPaymentMethods()
                
                KTPaymentManager().fetchPaymentsFromServer { (status, response) in
                    self.fetchnPaymentMethods()
                }
                                
                self.transactionDelegate?.showSuccessBanner("  ", "txt_payment_method_removed".localized())
                
            }
            else
            {
                let title = response["T"] != nil ? response["T"] as! String : "error_sr".localized()
                let message = response["M"] != nil ? response["M"] as! String : "please_dialog_msg_went_wrong".localized()
                self.transactionDelegate?.showErrorBanner(title, message)
            }
        }
    }
    
    func paymentMethodsCount() -> Int
    {
        return self.paymentMethods.count
    }
    
    func fetchnPaymentMethods()
    {
        
        let walletPaymentMethod = KTPaymentManager().getAllPayments().filter({$0.payment_type == "WALLET"})
        
        paymentMethods = KTPaymentManager().getAllPayments().filter({$0.payment_type != "WALLET"})
        
        //self.setSelectedPayment(0)

        if walletPaymentMethod.count > 0{
            self.transactionDelegate?.loadAvailableBalance(walletPaymentMethod[0].balance ?? "")
        }
        
        self.transactionDelegate?.reloadTableData()

    }
    
    func fetchTransactions()
    {
        transactions = KTWalletManager().getAllTransactions()
        self.transactionDelegate?.reloadTableData()
    }
    
    func fetchTransactionsServer()
    {
        KTWalletManager().fetchTransactionsFromServer(completion: { (status, response) in
            self.delegate?.hideProgressHud()
            self.fetchTransactions()
        })
    }
    
    func deleteAllTransactions() {
        KTWalletManager().deleteAllTransaction()
    }
    
    func convertDateFormat(inputDate: String) -> String {

         let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "h:mm a dd MMM yyyy"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    func pickupDate(forIdx idx: Int) -> String {
        var dateOfMonth : String = ""
        dateOfMonth = convertDateFormat(inputDate: transactions[idx].date ?? "")
        return dateOfMonth
    }
      
//      func pickupDateOfMonth(forIdx idx: Int) -> String{
//
//          var dateOfMonth : String = ""
//          if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
//
//              dateOfMonth = (bookings![idx] as KTBooking).pickupTime!.dayOfMonth()
//          }
//          return dateOfMonth
//      }
//
//      func pickupMonth(forIdx idx: Int) -> String{
//
//          var month : String = ""
//          if bookings != nil && idx < (bookings?.count)! && (bookings![idx] as KTBooking).pickupTime != nil{
//
//              month = (bookings![idx] as KTBooking).pickupTime!.threeLetterMonth()
//          }
//          return month
//      }
//
    
    func titelLabel(forCellIdx idx: Int) -> NSAttributedString {
        
        print("transactions", transactions)
        
        let combination = NSMutableAttributedString()

        let titleAttribute = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#525252"), NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 12.0)!]
        
        let paymentMethod = "\(transactions[idx].primaryMethod ?? "")"
        
        let titleString = NSMutableAttributedString(string: paymentMethod == "WALLET" ? paymentMethod.localized() : paymentMethod, attributes: titleAttribute)
        
        let typeAtrribute = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#00A8A8"), NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 12.0)!]
        
        let type = NSMutableAttributedString(string: (transactions[idx].transactionStatement ?? "") + "   ", attributes: typeAtrribute)
        combination.append(type)
//        combination.append(titleString)

//        if (transactions[idx].transactionType ?? "") == "CREDIT" {
//            let type = NSMutableAttributedString(string: (transactions[idx].transactionStatement ?? "") + "   ", attributes: typeAtrribute)
//            combination.append(type)
//            combination.append(titleString)
//        } else {
//            let type = NSMutableAttributedString(string: "str_paid_by".localized() + "   ", attributes: typeAtrribute)
//            combination.append(type)
//            combination.append(titleString)
//        }
        
        return combination
        
    }
    
    func detailLabel(forCellIdx idx: Int) -> NSAttributedString {
        
        let combination = NSMutableAttributedString()

        let currencyCodeAttribute = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#A5A5A5"), NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 11.0)!]

        if transactions[idx].transactionType == "CREDIT" {
            let amountAtrribute = [NSAttributedString.Key.foregroundColor: UIColor(hex: "#008000"), NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 14.0)!]
            let amount = NSMutableAttributedString(string: "+\(transactions[idx].amount ?? "")" + "   ", attributes: amountAtrribute)
            combination.append(amount)
        } else {
            let amountAtrribute = [NSAttributedString.Key.foregroundColor: UIColor(hexString: "#E43825"), NSAttributedString.Key.font: UIFont(name: "MuseoSans-700", size: 14.0)!]
            let amount = NSMutableAttributedString(string: "-\(transactions[idx].amount ?? "")" + "   ", attributes: amountAtrribute)
            combination.append(amount)
        }
        
        return combination
        
    }
    
    func descriptionLabel(forCellIdx idx: Int) -> String {
        
        guard transactions[idx].date != nil else {
            return ""
        }
        
        var dateOfMonth : String = ""
        dateOfMonth = convertDateFormat(inputDate: transactions[idx].date ?? "")
        return dateOfMonth
        
    }
    
    func transactionIcon(forCellIdx idx: Int) -> UIImage
    {
        
        print("transactions[idx].primaryMethod", transactions[idx].primaryMethod ?? "")
        
        if (transactions[idx].primaryMethod ?? "") == "str_wallet".localized().uppercased() && (transactions[idx].transactionType ?? "") == "CREDIT"{
            return UIImage(named: ImageUtil.getTransactionImage("CREDITWALLET"))!
        } else if (transactions[idx].primaryMethod ?? "") == "WALLET".localized().uppercased() {
            return UIImage(named: ImageUtil.getTransactionImage("PAIDWALLET"))!
        }
        else {
            return UIImage(named: ImageUtil.getTransactionImage("PAIDCARD"))!
        }
    }

    func numberOfTransactionRows() -> Int
    {
        return transactions.count == 0 ? 1 : transactions.count
    }
    
    func addCreditToWallet(amount: String) {
        
        let user = loginUserInfo()
        
        guard user.email != nil && !(user.email!.isEmpty) else {
            self.transactionDelegate?.showEnterEmailPopup()
            return
        }
        
        guard user.isEmailVerified else {
            self.transactionDelegate?.showVerifyEmailPopup(email: user.email ?? "")
            return
        }
                
        guard amount.count != 0 else {
            self.transactionDelegate?.showError?(title: "error_enter_amount".localized(), message: "")
            return
        }
        
        guard paymentSelected else {
            self.transactionDelegate?.showError?(title: "str_select_payment".localized(), message: "")
            return
        }
        
        guard (Int(amount) ?? 0) >= 30 else {
            self.transactionDelegate?.showError?(title: "str_amount_hint".localized(), message: "")
            return
        }
        
        self.transactionDelegate?.showProgressHud(show: true)

        let type = debitCardSelected == true ? "DEBITCARD" : ""
        
        KTWalletManager().addCreditAmount(paymentMethod: selectedPaymentMethod, amount: amount, type: type) { (status, response) in
            
            self.transactionDelegate?.hideProgressHud()

            if type == "DEBITCARD" {
                let paymentLink = ((response["D"] as? Array<[String:String]>)?[0])?["PaymentLink"] ?? ""
                print("test", ((response["D"] as? Array<[String:String]>)?[0])?["PaymentLink"] ?? "")
                self.transactionDelegate?.showCyberSecureViewController(url: paymentLink)
                return
            } else {
                self.transactionDelegate?.showSuccessBanner("", status)
                self.transactionDelegate?.closeView()
            }
                        
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
    
    func getPaymentData() {
        
        self.transactionDelegate?.showProgressHud(show: true)
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.transactionDelegate?.hideProgressHud()
            self.fetchnPaymentMethods()
        }
    }
    
    // Call the gateway to update the session.
    fileprivate func AddPaymentToServer(_ cardHolderName: String, _ cardNo: String, _ ccv: String, _ month: UInt, _ year: UInt) {
        // MARK: - Gateway Setup
        
        let gateway: Gateway = Gateway(region: Constants.GATEWAY_REGION, merchantId: Constants.MERCHANT_ID)
        
        var request = GatewayMap()
        request[at: "sourceOfFunds.provided.card.nameOnCard"] = cardHolderName
        request[at: "sourceOfFunds.provided.card.number"] = cardNo
        request[at: "sourceOfFunds.provided.card.securityCode"] = ccv
        request[at: "sourceOfFunds.provided.card.expiry.month"] = getRefinedMonth(month)
        request[at: "sourceOfFunds.provided.card.expiry.year"] = getRefinedYear(year)
        
        gateway.updateSession(sessionId, apiVersion: self.apiVersion, payload: request, completion: updateSessionHandler(_:))
    }
    
    func updateSession(_ cardHolderName:String, _ cardNo:String, _ ccv:String, _ month:UInt, _ year:UInt)
    {
        self.transactionDelegate?.showProgressHud(show: true, status: "verifying_card_information".localized())
        
        if(sessionId.count == 0 || apiVersion.count == 0)
        {
//
//            self.transactionDelegate?.showErrorBanner("error_sr".localized(), "txt_not_available".localized())
            
            KTPaymentManager().createSessionForPaymentAtServer { (status, response) in
                if status == Constants.APIResponseStatus.SUCCESS
                {
//                    self.transactionDelegate?.hideProgressHud()
                    self.sessionId = (response[Constants.PaymentResponseAPIKey.SessionId] as? String)!
                    let apiVersionInt : Int = ((response[Constants.PaymentResponseAPIKey.ApiVersion] as? Int)!)
                    self.apiVersion = String(apiVersionInt)
                    self.AddPaymentToServer(cardHolderName, cardNo, ccv, month, year)
                }
            }
            
        }
        else
        {
            AddPaymentToServer(cardHolderName, cardNo, ccv, month, year)
        }
    }
    
    // MARK: - Handle the Update Response call the gateway to update the session
    fileprivate func updateSessionHandler(_ result: GatewayResult<GatewayMap>)
    {
        self.transactionDelegate?.hideProgressHud()
        
        switch result
        {
        case .success(_):
            self.transactionDelegate?.showProgressHud(show: true, status: "adding_card_payment_str".localized())
            updateCardToServer()
            break;
            
        case .error(let error):
            self.transactionDelegate?.hideCardIOPaymentController()
            
            var message = "Unable to update session."
            if case GatewayError.failedRequest( _, let explination) = error
            {
                message = explination
            }
            
            DispatchQueue.main.async {
                self.transactionDelegate?.showErrorBanner("   ", message)
            }
            
            break;
        }
    }
    
    func updateCardToServer()
    {
        KTPaymentManager().updateMPGSSuccessAtServer(sessionId, apiVersion, completion: { (status, response) in
            
            self.transactionDelegate?.hideProgressHud()
            self.transactionDelegate?.hideCardIOPaymentController()
            
            if status == Constants.APIResponseStatus.SUCCESS
            {
                let html = response["Html"] as? String
                if(html != nil)
                {
                    DispatchQueue.main.async {
                        self.transactionDelegate?.show3dSecureController(html!)
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
                self.transactionDelegate?.showErrorBanner("   ", response["M"] as! String)
            }
        })
    }
    
    func kmpgs3dSecureFailure(_ result: String)
    {
        self.transactionDelegate?.showErrorBanner("   ", result)
    }
    
    func updatePaymentMethod()
    {
        AnalyticsUtil.trackAddPaymentMethod("")
        self.transactionDelegate?.showProgressHud(show: true, status: "dialog_msg_updating_profile".localized())
        KTPaymentManager().fetchPaymentsFromServer{(status, response) in
            self.transactionDelegate?.hideProgressHud()
            self.transactionDelegate?.showSuccessBanner("  ", status)
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
                self.fetchSessionInfo()
                self.transactionDelegate?.showAddCardVC()
            }
            else
            {
                self.transactionDelegate?.showVerifyEmailPopup(email: user.email ?? "")
            }
        }
        else
        {
            self.transactionDelegate?.showEnterEmailPopup()
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
    
    fileprivate func setSelectedPayment(_ idx: Int) {
        
        guard paymentMethods.count != 0 else{
            debitCardSelected = true
            return
        }
        
        paymentSelected = true
        
        selectedPaymentMethod = paymentMethods[idx]
        
        var modifiedPaymentMethods = [KTPaymentMethod]()
        for item in paymentMethods {
            item.is_selected = (item.source == selectedPaymentMethod.source)
            modifiedPaymentMethods.append(item)
        }
        
        paymentMethods = modifiedPaymentMethods
    }
    
    func rowSelected(atIndex idx: Int) {
        
        debitCardSelected = false
        
        setSelectedPayment(idx)
        
        self.transactionDelegate?.reloadTableData()
        
        
    }
    
    func debitRowSelected(atIndex idx: Int) {
                
        debitCardSelected = debitCardSelected == false ? true : false
        paymentSelected = debitCardSelected
        
        var modifiedPaymentMethods = [KTPaymentMethod]()
        for item in paymentMethods {
            item.is_selected = false
            modifiedPaymentMethods.append(item)
        }
        
        paymentMethods = modifiedPaymentMethods
        
        self.transactionDelegate?.reloadTableData()
        
        
    }
    
    func debitCardSelection(forCellIdx idx: Int) -> UIColor {
        if(debitCardSelected) {
            return UIColor(hexString: "#00A8A8")
        }
        else {
            return UIColor(hexString: "#EBEBEB")
        }
    }
    
    func debitCardSelectionStatusIcon(forCellIdx idx: Int) -> UIImage {
        if(debitCardSelected) {
            return #imageLiteral(resourceName: "checked_icon")
        } else {
            return #imageLiteral(resourceName: "uncheck_icon")
        }
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
