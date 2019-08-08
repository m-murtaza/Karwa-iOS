//
//  PaymentManager.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/28/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import Foundation

let PAYMENTS_SYNC_TIME = "PaymentsSyncTime"

class KTPaymentManager: KTDALManager
{
    func fetchPaymentsFromServer(completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String: Any] = [Constants.SyncParam.Complaints: syncTime(forKey:PAYMENTS_SYNC_TIME)]
        
        self.get(url: Constants.APIURL.GetPayments, param: param, completion: completionBlock) { (responseData,cBlock) in
            
            print(responseData)
            if(responseData.count > 0)
            {
                if(responseData[Constants.ResponseAPIKey.Data] != nil)
                {
                    self.deleteAllPaymentMethods()

                    self.addPaymentsToDB(responseData: responseData[Constants.ResponseAPIKey.Data] as! [Any])
                    
                    self.makeOnePaymentMethodDefault()
                    
                    self.updateSyncTime(forKey: PAYMENTS_SYNC_TIME)
                }
            }
            else if(responseData.count == 0)
            {
                self.deleteAllPaymentMethods()
            }

            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
    }
    
    func addPaymentsToDB(responseData : [Any])
    {
        for  case let newPayment as [AnyHashable: Any] in responseData
        {
            addPaymentToDB(payment: newPayment)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func addPaymentToDB(payment : [AnyHashable: Any])
    {
        if payment[Constants.PaymentResponseAPIKey.Source] != nil
        {
            let newPayment = KTPaymentMethod.mr_createEntity(in: NSManagedObjectContext.mr_default())
            newPayment?.source = (payment[Constants.PaymentResponseAPIKey.Source] as? String)!
            newPayment?.payment_type = (payment[Constants.PaymentResponseAPIKey.PaymentType] as? String)!
            newPayment?.last_four_digits = (payment[Constants.PaymentResponseAPIKey.LastFourDigits] as? String)!
            newPayment?.expiry_month = (payment[Constants.PaymentResponseAPIKey.ExpiryMonth] as? String)!
            newPayment?.expiry_year = (payment[Constants.PaymentResponseAPIKey.ExpiryYear] as? String)!
            newPayment?.brand = (payment[Constants.PaymentResponseAPIKey.Brand] as? String)!
//            newPayment?.balance = (payment[Constants.PaymentResponseAPIKey.Balance] as? String)!
            newPayment?.is_removable = (payment[Constants.PaymentResponseAPIKey.IsRemovable] as? Bool)!
        }
    }
    
    func makeDefaultPaymentMethod(defaultPaymentMethod paymentMethod : KTPaymentMethod)
    {
        for item in getAllPayments()
        {
            item.is_selected = (item.source == paymentMethod.source)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func makeOnePaymentMethodDefault()
    {
        let payments = getAllPayments()
        if(payments.count > 0)
        {
           payments[0].is_selected = true
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }

    func makeOnePaymentMethodDefaultAndReturn() -> [KTPaymentMethod]
    {
        let payments = getAllPayments()
        if(payments.count > 0)
        {
            payments[0].is_selected = true
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        
        return payments
    }
    
    func getAllPayments() -> [KTPaymentMethod]
    {
        var paymentMethods : [KTPaymentMethod] = []
        
        paymentMethods = KTPaymentMethod.mr_findAllSorted(by: "brand", ascending: true, in: NSManagedObjectContext.mr_default()) as! [KTPaymentMethod]
        
        return paymentMethods
    }
    
    func getDefaultPayment() -> KTPaymentMethod?
    {
        let predicate : NSPredicate = NSPredicate(format:"is_selected = %d" , true)
        
//        guard let selectedPayment = KTPaymentMethod.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())
//        else
//        {
//            return nil
//        }
        
        return KTPaymentMethod.mr_findFirst(with: predicate, in: NSManagedObjectContext.mr_default())
    }
    
    func deleteAllPaymentMethods()
    {
        let predicate : NSPredicate = NSPredicate(format:"is_removable = %d" , true)
        
        KTPaymentMethod.mr_deleteAll(matching: predicate)
    }
    
    func deletePaymentMethods(_ paymentMethod : KTPaymentMethod)
    {
        let predicate : NSPredicate = NSPredicate(format:"source = %d" , paymentMethod.source!)
        
        KTPaymentMethod.mr_deleteAll(matching: predicate)
    }
    
    func createSessionForPaymentAtServer(completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.MPGSSessionAPIKey.SessionId: ""]

        self.post(url: Constants.APIURL.MPGSCreateSession, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
    }
    
    func updateMPGSSuccessAtServer(_ sessionId:String, _ apiVersion:String, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.MPGSSessionAPIKey.SessionId: sessionId,
                                    Constants.MPGSSessionAPIKey.ApiVersion: apiVersion]
        
        self.post(url: Constants.APIURL.MPGSSuccessToServer, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
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
    
    func payTripAtServer(_ source: String, _ data : String, _ tipValue: String, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.PayTripAPIKey.Source: source,
                                    Constants.PayTripAPIKey.Data: data,
                                    Constants.PayTripAPIKey.Tip: tipValue]
        
        self.put(url: Constants.APIURL.PayTrip, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
        )
    }
    
    func removeAllPaymentData()
    {
        deleteAllPaymentMethods()
        KTDALManager().removeSyncTime(forKey: PAYMENTS_SYNC_TIME)
    }
}
