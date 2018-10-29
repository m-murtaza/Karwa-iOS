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
        if payment[Constants.PaymentResponseAPIKey.Id] != nil
        {
            let newPayment = KTPaymentMethod.mr_createEntity(in: NSManagedObjectContext.mr_default())
            
            newPayment?.id = (payment[Constants.PaymentResponseAPIKey.Id] as? Int16)!
            newPayment?.payment_type = (payment[Constants.PaymentResponseAPIKey.PaymentType] as? String)!
            newPayment?.last_four_digits = (payment[Constants.PaymentResponseAPIKey.LastFourDigits] as? String)!
            newPayment?.expiry_month = (payment[Constants.PaymentResponseAPIKey.ExpiryMonth] as? String)!
            newPayment?.expiry_year = (payment[Constants.PaymentResponseAPIKey.ExpiryYear] as? String)!
            newPayment?.brand = (payment[Constants.PaymentResponseAPIKey.Brand] as? String)!
//            newPayment?.balance = (payment[Constants.PaymentResponseAPIKey.Balance] as? String)!
            newPayment?.is_removable = (payment[Constants.PaymentResponseAPIKey.IsRemovable] as? Bool)!
        }
    }
    
    func getAllPayments() -> [KTPaymentMethod]
    {
        var paymentMethods : [KTPaymentMethod] = []
        
        paymentMethods = KTPaymentMethod.mr_findAllSorted(by: "brand", ascending: true, in: NSManagedObjectContext.mr_default()) as! [KTPaymentMethod]
        
        return paymentMethods
    }
    
    func deleteAllPaymentMethods()
    {
        let predicate : NSPredicate = NSPredicate(format:"is_removable = %d" , true)
        
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
    
    func updateMPGSSuccessAtServer(mpgsSession: MPGSSession, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.MPGSSessionAPIKey.SessionId: mpgsSession.sessionId,
                                    Constants.MPGSSessionAPIKey.ApiVersion: mpgsSession.apiVersion]
        
        self.post(url: Constants.APIURL.MPGSSuccessToServer, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
    }
    
    func deletePaymentAtServer(paymentMethod: KTPaymentMethod, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.MPGSSessionAPIKey.SessionId: ""]

        let url = Constants.APIURL.DeletePaymentMethod + String(paymentMethod.id)
        
        self.delete(url: url, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
    }
    
    func payTripAtServer(payTrip: PayTripBeanForServer, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.PayTripAPIKey.DriverId: payTrip.driverId,
                                    Constants.PayTripAPIKey.PaymentMethodId: payTrip.paymentMethodId,
                                    Constants.PayTripAPIKey.TotalFare: payTrip.totalFare,
                                    Constants.PayTripAPIKey.TripId: payTrip.tripId,
                                    Constants.PayTripAPIKey.TripType: payTrip.tripType,
                                    Constants.PayTripAPIKey.U: payTrip.u,
                                    Constants.PayTripAPIKey.S: payTrip.s,
                                    Constants.PayTripAPIKey.E: payTrip.e]
        
        self.put(url: Constants.APIURL.PayTrip, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
        )
    }
}