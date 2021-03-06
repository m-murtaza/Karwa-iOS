//
//  ComplaintsManager.swift
//  KarwaRide
//
//  Created by Sam Ash on 10/4/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation

let COMPLAINTS_SYNC_TIME = "ComplaintsSyncTime"

class KTComplaintsManager: KTDALManager {
    
    func fetchComplaintsFromServer(completion completionBlock:@escaping KTDALCompletionBlock)
    {
        let param : [String: Any] = [Constants.SyncParam.Complaints: syncTime(forKey:COMPLAINTS_SYNC_TIME)]

        self.get(url: Constants.APIURL.GetComplaints, param: param, completion: completionBlock) { (responseData,cBlock) in

            print(responseData)
            if(responseData.count > 0)
            {
                if(responseData[Constants.ResponseAPIKey.Data] != nil)
                {
                    self.addComplaintsToDB(responseData: responseData[Constants.ResponseAPIKey.Data] as! [Any])
                    
                    self.updateSyncTime(forKey: COMPLAINTS_SYNC_TIME)
                }
            }

            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        }
    }
    
    func addComplaintsToDB(responseData : [Any])
    {
        guard responseData.count > 0 else {
            return
        }
        
        KTComplaint.mr_truncateAll()

        for  case let newComplaint as [AnyHashable: Any] in responseData
        {
            addComplaintToDB(complaint: newComplaint)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }

    func addComplaintToDB(complaint : [AnyHashable: Any])
    {
        if complaint[Constants.ComplaintsResponseAPIKey.CategoryId] != nil
        {
            let newComplaint = KTComplaint.mr_createEntity(in: NSManagedObjectContext.mr_default())

            newComplaint?.categoryId = (complaint[Constants.ComplaintsResponseAPIKey.CategoryId] as? Int32)!
            newComplaint?.complaintType = (complaint[Constants.ComplaintsResponseAPIKey.ComplaintType] as? Int16)!
            newComplaint?.issueId = (complaint[Constants.ComplaintsResponseAPIKey.IssueId] as? Int32)!
            newComplaint?.issue = complaint[Constants.ComplaintsResponseAPIKey.Name] as? String
            newComplaint?.order = (complaint[Constants.ComplaintsResponseAPIKey.Order] as? Int32)!
        }
    }
    
    func getAllComplaints() -> [KTComplaint]
    {
        return getAllComplaints(categoryId: 0)
    }
    
    func getAllComplaints(categoryId id : Int) -> [KTComplaint]
    {
        var complaints : [KTComplaint] = []
        
        let predicate : NSPredicate = NSPredicate(format:"categoryId = %d" , id)

        complaints = KTComplaint.mr_findAllSorted(by: "order", ascending: true, with: predicate, in: NSManagedObjectContext.mr_default()) as! [KTComplaint]
        
        return complaints
    }
    
    func createComplaintAtServer(complaint: ComplaintBeanForServer, completion completionBlock: @escaping KTDALCompletionBlock)
    {
        let param : NSDictionary = [Constants.ComplaintParams.IssueID: complaint.issueId,
                                    Constants.ComplaintParams.CategoryID: complaint.categoryId,
                                    Constants.ComplaintParams.ComplaintType: complaint.complaintType,
//                                    Constants.ComplaintParams.Name : complaint.name!,
//                                    Constants.ComplaintParams.Order: complaint.order,
                                    Constants.ComplaintParams.bookingId: complaint.bookingId,
                                    Constants.ComplaintParams.remarks : complaint.remarks,
                                    Constants.ComplaintParams.TripType : complaint.tripType]

        self.post(url: Constants.APIURL.CreateComplaint, param: param as? [String : Any], completion: completionBlock, success:
            { (responseData,cBlock) in
                    completionBlock(Constants.APIResponseStatus.SUCCESS,responseData)
            }
        )
    }
}
