//
//  KTSetHomeViewModel.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
protocol KTSetHomeWorkViewModelDelegate {
    func typeOfBookmark() -> BookmarkType
    func UpdateUI(name bookmarkName:String, location: CLLocationCoordinate2D)
}

class KTSetHomeWorkViewModel: KTBaseViewModel {

    var bookmark : KTBookmark?
    
    override func viewDidLoad() {
        KTBookmarkManager().fetchHomeWork { (status, response) in
            if status == Constants.APIResponseStatus.SUCCESS {
                
                if (self.delegate as! KTSetHomeWorkViewModelDelegate).typeOfBookmark() == BookmarkType.home {
                    self.bookmark = KTBookmarkManager().getHome()
                }
                else{
                    self.bookmark = KTBookmarkManager().getWork()
                }
                
                (self.delegate as! KTSetHomeWorkViewModelDelegate).UpdateUI(name: (self.bookmark?.address)!, location: CLLocationCoordinate2D(latitude: (self.bookmark?.latitude)!,longitude: (self.bookmark?.longitude)!))
            }
            else {
                self.delegate?.showError!(title: response[Constants.ResponseAPIKey.Title] as! String, message: response[Constants.ResponseAPIKey.Message] as! String)
            }
        }
    }
}
