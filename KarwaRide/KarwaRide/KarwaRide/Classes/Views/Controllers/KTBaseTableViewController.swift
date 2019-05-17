//
//  KSBaseTableViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 11/22/17.
//  Copyright © 2017 Karwa. All rights reserved.
//

import UIKit
import SVProgressHUD
import Toast_Swift
import NotificationBannerSwift
class KTBaseTableViewController: UITableViewController,KTViewModelDelegate
{
    var viewModel : KTBaseViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func showProgressHud(show : Bool, status:String){
        if show {
            SVProgressHUD.show(withStatus: status)
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
        
    }
    func showPopupMessage(_ title: String, _ message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func hideProgressHud() {
        
        showProgressHud(show: false)
    }
    func showProgressHud(show: Bool) {
        if show {
            SVProgressHUD.show();
            userIntraction(enable: false)
        }
        else {
            SVProgressHUD.dismiss()
            userIntraction(enable: true)
        }
    }
    
    func showTaskCompleted(withMessage msg: String) {
        SVProgressHUD.show(UIImage(named: "light-check-mark")!, status: msg)
        SVProgressHUD.dismiss(withDelay: 1.0)
    }
    
    func userIntraction(enable: Bool) {
        if enable {
            
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        else {
            
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func performSegue(name:String) {
        
        self.performSegue(withIdentifier: name, sender: self)
    }
    
    func viewStoryboard() -> UIStoryboard {
        return self.storyboard!
        
    }
    
    func showToast(message : String)
    {
        // create a new style
        var style = ToastStyle()
        style.backgroundColor = .white
        style.messageFont = .systemFont(ofSize: 13)
        style.messageColor = .black
        
        self.view.makeToast(message, duration: 3.0, position: .center, style: style)
        
    }
    
    func showSuccessBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.success)
    }
    
    func showInfoBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.info)
    }
    
    func showErrorBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.danger)
    }
    
    func showNonBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.none)
    }
    
    func showWarningBanner(_ title: String, _ message: String)
    {
        showBanner(title, message, BannerStyle.warning)
    }
    
    func showBanner(_ title: String, _ message: String, _ bannerStyle: BannerStyle)
    {
        let banner = NotificationBanner(title: title, subtitle: message, style: bannerStyle)
        banner.show()
        DispatchQueue.main.asyncAfter(deadline: (.now() + 4))
        {
            banner.dismiss()
        }
    }
}
