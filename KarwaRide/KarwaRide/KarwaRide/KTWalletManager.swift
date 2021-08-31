//
//  KTWalletManager.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 11/04/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import Foundation


let TRANSACTIONS_SYNC_TIME = "TransactionsSyncTime"

class KTWalletManager: KTDALManager {
    
    func addCreditAmount(paymentMethod: KTPaymentMethod, amount: String, type: String,completion completionBlock:@escaping KTDALCompletionBlock) {
        
        let params : NSMutableDictionary = [Constants.WalletTopUpParam.amount : amount]
        params[Constants.LoginParams.DeviceType] = Constants.DeviceTypes.iOS
        
        if type == "" {
            params[Constants.WalletTopUpParam.methodId] = AESEncryption().encrypt(paymentMethod.source ?? "")
            params[Constants.WalletTopUpParam.method] = paymentMethod.payment_type ?? ""
            self.post(url: Constants.APIURL.walletTopup, param: (params as! [String : Any]), completion: completionBlock) { (response,  cBlock) in
                print(response)
                completionBlock(Constants.APIResponseStatus.SUCCESS,response)
            }
        } else {
            params[Constants.WalletTopUpParam.method] = type
            self.post(url: Constants.APIURL.walletTopup, param: (params as! [String : Any]), completion: completionBlock) { (response,  cBlock) in
                print(response)
                completionBlock(Constants.APIResponseStatus.SUCCESS,response)
            }
        }
        
        
    }
    
    func fetchTransactionsFromServer(completion completionBlock:@escaping KTDALCompletionBlock)
    {
        
        self.get(url: Constants.APIURL.GetTransactions, param: nil, completion: completionBlock) { (responseData,cBlock) in
            
            print(responseData)
            if(responseData.count > 0)
            {
                if(responseData[Constants.ResponseAPIKey.Data] != nil)
                {
                    
                    self.deleteAllTransaction()

                    self.addTransactionsToDB(responseData: responseData[Constants.ResponseAPIKey.Data] as! [Any])
                                        
                    self.updateSyncTime(forKey: TRANSACTIONS_SYNC_TIME)
                    
                }
            }
            else if(responseData.count == 0)
            {

            }

            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
    }
    
    func addTransactionsToDB(responseData : [Any])
    {
        for  case let newPayment as [AnyHashable: Any] in responseData
        {
            addTransactionToDB(transaction: newPayment)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func addTransactionToDB(transaction : [AnyHashable: Any])
    {
        if transaction[Constants.TransactionResponseAPIKey.TransactionTime] != nil
        {
            let transactionEntity = KTTransactions.mr_createEntity(in: NSManagedObjectContext.mr_default())
            
            
            let transactionPaymentMethod = transaction[Constants.TransactionResponseAPIKey.PaymentMethod] as? [String:Any]
            
            
            transactionEntity?.primaryMethod = ((transactionPaymentMethod?[Constants.TransactionResponseAPIKey.PrimaryInfo]) as? String) ?? ""

            transactionEntity?.transactionType = (transaction[Constants.TransactionResponseAPIKey.TransactionType] as? String) ?? ""
            
            transactionEntity?.transactionStatement = (transaction[Constants.TransactionResponseAPIKey.TransactionStatement] as? String) ?? ""
            
            transactionEntity?.date = (transaction[Constants.TransactionResponseAPIKey.TransactionTime] as? String) ?? ""
            
            transactionEntity?.amount = (transaction[Constants.TransactionResponseAPIKey.Amount] as? String) ?? ""
            
        }
    }
    
    func getAllTransactions() -> [KTTransactions] {
        
        var paymentMethods : [KTTransactions] = []
        paymentMethods = KTTransactions.mr_findAllSorted(by: "date", ascending: false, in: NSManagedObjectContext.mr_default()) as! [KTTransactions]
        return paymentMethods
        
    }
    
    func deleteAllTransaction() {
        
        let predicate : NSPredicate = NSPredicate(format:"date contains[c]         %@" , "T")
        KTTransactions.mr_deleteAll(matching: predicate)
    
    }
    
    func deletePaymentAtServer(paymentMethod: String, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.PaymentResponseAPIKey.Source: paymentMethod]

        let url = Constants.APIURL.DeletePaymentMethod
        
        self.post(url: url, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
    }
    
    func deletePaymentMethods(_ paymentMethod : KTPaymentMethod)
    {
        let predicate : NSPredicate = NSPredicate(format:"source = %d" , paymentMethod.source!)
        
        KTPaymentMethod.mr_deleteAll(matching: predicate)
        
        KTPaymentManager().getAllPayments()
        
    }
        
}
