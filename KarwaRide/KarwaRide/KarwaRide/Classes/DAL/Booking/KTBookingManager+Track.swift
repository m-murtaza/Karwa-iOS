//
//  KTBookingManager+Track.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/16/18.
//  Copyright © 2018 Karwa. All rights reserved.
//
import CoreLocation

//let TrackTaxiStatus = "0,1"
//let TrackTaxiMaxFectchCount = 5
let TrackTaxiStatus = "1"
let TrackTaxiMaxFectchCount = 1
let TrackTaxiDefaultRadius = 100000.0

extension KTBookingManager
{
    
    func vehiclesNearCordinate(coordinate:CLLocationCoordinate2D, vehicleType: VehicleType, completion completionBlock: @escaping KTDALCompletionBlock) -> Void {
        let param : NSMutableDictionary = [Constants.TrackTaxiParams.Status: TrackTaxiStatus,
                                           Constants.TrackTaxiParams.Lat : coordinate.latitude,
                                           Constants.TrackTaxiParams.Lon: coordinate.longitude,
                                           Constants.TrackTaxiParams.Radius: TrackTaxiDefaultRadius,
                                           //Constants.TrackTaxiParams.VehicleType : vehicleType.rawValue,
                                           Constants.TrackTaxiParams.Limit: TrackTaxiMaxFectchCount]
       
        self.get(url: Constants.APIURL.TrackTaxi, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        })
    }
    
    func trackVechicle(jobId:String,vehicleNumber:String, completion completionBlock: @escaping KTDALCompletionBlock) {
        
        trackVechicle(jobId: jobId, vehicleNumber: vehicleNumber, false, completion: completionBlock)
    }
    
    func trackVechicle(jobId:String,vehicleNumber:String, _ withStatus: Bool, completion completionBlock: @escaping KTDALCompletionBlock) {
        
        let vNumber : String = vehicleNumber.urlEncodeString()!
        let jId : String = jobId.urlEncodeString()!
        let url : String = withStatus ? "\(Constants.APIURL.trackVechicle)/\(jId)/\(vNumber)?includeStatus=1" : "\(Constants.APIURL.trackVechicle)/\(jId)/\(vNumber)"
        
        self.get(url: url,param: nil,completion: completionBlock,success: {
            (responseData,cBlock) in
            cBlock(Constants.APIResponseStatus.SUCCESS, responseData)
        })
    }
}


