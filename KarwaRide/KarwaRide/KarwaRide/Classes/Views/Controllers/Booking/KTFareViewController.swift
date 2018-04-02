//
//  KTFareViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 4/1/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit
protocol KTFareViewDelegate {
    func btnBackTapped()
}

class KTFareViewController: KTBaseViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var tblView : UITableView!
    var delegate : KTFareViewDelegate?
    
    var breakdown : [String : String] = ["" : ""]
    var keys : [String]?
    //var headingTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateView(KeyValue b: [String:String], title : String ) {
        if title != "" {
            lblTitle.text = title
        }
        breakdown = b
        keys = Array(breakdown.keys)
        tblView.reloadData()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        delegate?.btnBackTapped()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 18.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numRow = 0
        if keys != nil {
            numRow =  (keys?.count)!
        }
        return numRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTFareTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FareCellIdentifier") as! KTFareTableViewCell
        cell.updateCell(key: keys![indexPath.row], value: breakdown[keys![indexPath.row]]!)
        return cell
    }

}

class KTFareTableViewCell : UITableViewCell {
    
    @IBOutlet weak var lblKey : UILabel!
    @IBOutlet weak var lblValue : UILabel!
    
    func updateCell(key k:String, value v: String)  {
        lblKey.text = k
        lblValue.text = v
    }
}
