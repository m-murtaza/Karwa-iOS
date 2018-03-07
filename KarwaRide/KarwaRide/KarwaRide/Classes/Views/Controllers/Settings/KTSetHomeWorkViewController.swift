//
//  KTSetHomeWorkViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 3/7/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
import CoreLocation
enum BookmarkType : Int{
    case home = 1
    case work = 2
}

class KTSetHomeWorkViewController: KTBaseViewController, KTSetHomeWorkViewModelDelegate {

    public var bookmarkType : BookmarkType = BookmarkType.home
    
    @IBOutlet weak var txtBookmarkType: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var imgBookmarkTypeIcon: UIImageView!
    @IBOutlet weak var imgBookmarkAddressIcon: UIImageView!
    
    
    override func viewDidLoad() {
        viewModel = KTSetHomeWorkViewModel(del: self)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func typeOfBookmark() -> BookmarkType {
        
        return bookmarkType
    }
    func UpdateUI(name bookmarkName:String, location: CLLocationCoordinate2D) {
        
        txtAddress.text = bookmarkName
        txtBookmarkType.text = (bookmarkType == BookmarkType.home) ? "Set Home address" : "Set Work address"
        imgBookmarkTypeIcon.image = UIImage(named: (bookmarkType == BookmarkType.home) ? "APICHome" : "APICWork")
        imgBookmarkAddressIcon.image = UIImage(named: (bookmarkType == BookmarkType.home) ? "SHWIconHome" : "SHWIconWork")
    }
}
