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
    @IBOutlet weak var btnHideFareBreakdown: UIButton!
    var delegate : KTFareViewDelegate?
    
    var breakdown : [String : String] = [:]
    var keys : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHideBackFareDetailsBtn(hide: false)
        // Do any additional setup after loading the view.
    }

    func showHideBackFareDetailsBtn(hide: Bool)
    {
        btnHideFareBreakdown.isHidden = hide
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateView(KeyValue b: [[String:String]], title : String ) {
        if title != "" {
            lblTitle.text = title
        }
        breakdown = [:]
        keys = []
        for brkDown in b {
            
            breakdown[Array(brkDown.keys)[0]] = brkDown[Array(brkDown.keys)[0]]
            keys.append(Array(brkDown.keys)[0])
        }
        showHideBackFareDetailsBtn(hide: false)
        tblView.reloadData()
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        breakdown = [:]
        keys = []
        showHideBackFareDetailsBtn(hide: false)
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

        return keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTFareTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FareCellIdentifier") as! KTFareTableViewCell
        cell.updateCell(key: keys[indexPath.row], value: breakdown[keys[indexPath.row]]!)
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
