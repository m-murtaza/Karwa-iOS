//
//  KTKarwaPlanTripViewmodel.swift
//  KarwaRide
//
//  Created by Apple on 01/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import Foundation

class KTKarwaPlanTripViewmodel: KTBaseViewModel {
    
    var routeModel: KarwaBusRoute?
    
    func fetchJourneyPlannerRoutes() {
        KTKarwaBusBookingManager().getRoutesWithSync(requestParameter: RequestParameters()) { [weak self] (status, response) in
            
            self?.delegate?.hideProgressHud()

            do {
                
                print(mockRoute.json)
                
                let jsonObjectData = Data(mockRoute.json.utf8)//mockRoute.json.data(using: .utf8)!
                // Decode the json data to a Candidate struct
                self?.routeModel = try? JSONDecoder().decode(KarwaBusRoute.self, from: jsonObjectData)
                print(self?.routeModel)
               
            } catch {
                print(error.localizedDescription)
            }
            
            print(response)
        }
    }
    
    func setPickAddress(pAddress : KTGeoLocation) {
        
    }
    
    func setDropAddress(dAddress : KTGeoLocation) {

    }
    
    func dismiss() {
        delegate?.dismiss()
    }
    
    func btnPickupAddTapped(){
        delegate?.performSegue(name: "seguePlanTripToPickUpAddress")
    }
    
    func btnDropAddTapped() {
        delegate?.performSegue(name: "seguePlanTripToDropOffAddress")
    }
    
    
}
