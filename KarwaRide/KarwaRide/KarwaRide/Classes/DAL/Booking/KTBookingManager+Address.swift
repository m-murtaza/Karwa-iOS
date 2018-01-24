//
//  KTBookingManager+Address.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 1/24/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import CoreLocation

extension KTBookingManager
{
    func addressForLocation(location: CLLocationCoordinate2D,completion completionBlock: @escaping KTDALCompletionBlock ) {
        
        let param : NSDictionary = [Constants.AddressPickParams.Lat: location.latitude,
                                    Constants.AddressPickParams.Lon: location.longitude]
        self.get(url: Constants.APIURL.AddressPick, param: param as? [String : Any], completion: completionBlock, success: {
            (responseData,cBlock) in
            print(responseData)
            cBlock(Constants.APIResponseStatus.SUCCESS,responseData)
        })
    }
    
}
