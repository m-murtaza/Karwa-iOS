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

class KTSetHomeWorkViewController: KTBaseViewController, KTSetHomeWorkViewModelDelegate,UITableViewDelegate,UITableViewDataSource {

    public var bookmarkType : BookmarkType = BookmarkType.home
    public var selectedInputMechanism : SelectedInputMechanism = SelectedInputMechanism.ListView
    public var previousView : KTSettingsViewController?
    
    @IBOutlet weak var txtBookmarkType: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var imgBookmarkTypeIcon: UIImageView!
    @IBOutlet weak var imgBookmarkAddressIcon: UIImageView!
    @IBOutlet weak var tblView: UITableView!
    
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
    
    func UpdateAddressText(address add:String) {
        
        txtAddress.text = add
    }
    
    func showSuccessAltAndMoveBack() {
        let alertController = UIAlertController(title: "\((bookmarkType == BookmarkType.home) ? "Home" : "Work") Updated", message: "Your \((bookmarkType == BookmarkType.home) ? "Home" : "Work") address is updated", preferredStyle: .alert)
        
        //let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.previousView?.dismiss()
        }
        
        //alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel as! KTSetHomeWorkViewModel).numberOfRow()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AddressPickCell = tableView.dequeueReusableCell(withIdentifier: "AddPickCellIdentifier", for: indexPath) as! AddressPickCell
        
        cell.addressTitle.text = (viewModel as! KTSetHomeWorkViewModel).addressTitle(forRow: indexPath.row)
        cell.addressArea.text = (viewModel as! KTSetHomeWorkViewModel).addressArea(forRow: indexPath.row)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        (viewModel as! KTSetHomeWorkViewModel).didSelectRow(at:indexPath.row)
    }
    
    func loadData() {
        tblView.reloadData()
    }
}
