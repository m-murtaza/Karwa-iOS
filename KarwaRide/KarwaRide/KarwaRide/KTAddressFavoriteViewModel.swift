//
//  KTAddressFavoriteViewModel.swift
//  KarwaRide
//
//  Created by Umer Afzal on 02/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import Foundation


protocol KTAddressFavoriteViewModelDelegate: KTViewModelDelegate {
  var locationName: String {  get }
  var location: KTGeoLocation {  get }
  func locationSavedSuccessfully(location: KTGeoLocation)
}

class KTAddressFavoriteViewModel: KTBaseViewModel {
  
  weak var del: KTAddressFavoriteViewModelDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    del = (delegate as! KTAddressFavoriteViewModelDelegate)
  }
  
  func saveLocation() {
    guard let delegate = del else { return  }
    if delegate.locationName.isEmpty {
      delegate.showError?(title: "Error", message: "Location name cannot be empty")
      return
    }
    let favlocation = delegate.location
    KTBookmarkManager().saveFavorite(name: delegate.locationName,
                                     location: favlocation)
    favlocation.geolocationToBookmark?.mr_delete(in: NSManagedObjectContext.mr_default())
    favlocation.mr_delete(in: NSManagedObjectContext.mr_default())
    NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    delegate.showTaskCompleted(withMessage: "Address has been saved as favorite")
    delegate.locationSavedSuccessfully(location: delegate.location)
  }
  
}
