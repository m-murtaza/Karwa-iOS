//
//  KTNewAddCreditCardVM.swift
//  KarwaRide
//
//  Created by Sam Ash on 13/12/2021.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation

protocol KTNewAddCreditCardVMDelegate : KTViewModelDelegate{
    func loadURL(url: String)
    func closeView()
}

class KTNewAddCreditCardVM: KTBaseViewModel {

    var del : KTNewAddCreditCardVMDelegate?

    var sessionId = ""
    var path = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        del = self.delegate as? KTNewAddCreditCardVMDelegate
        
        createSession()
    }
    
    func createSession()
    {
        self.del?.showProgressHud(show: true, status: "str_loading".localized())
        KTPaymentManager().createMPGSSession { (status, response) in

            self.del?.hideProgressHud()

            if status == Constants.APIResponseStatus.SUCCESS
            {
                self.sessionId = (response[Constants.PaymentResponseAPIKey.SessionId] as? String)!
                self.path = (response[Constants.PaymentResponseAPIKey.Path] as? String)!
                self.del?.loadURL(url: self.path)
            }
            else
            {
                (self.delegate as! KTNewAddCreditCardVMDelegate).showError!(title: "error_sr".localized(),message: "please_dialog_msg_went_wrong".localized())
            }
        }
    }
}
