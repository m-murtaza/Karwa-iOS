//
//  KTKarwaBusViewController.swift
//  KarwaRide
//
//  Created by Apple on 29/12/21.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit

class KTKarwaBusViewController: KTBaseCreateBookingController {

    @IBOutlet weak var busRouteTableView: UITableView!
    @IBOutlet weak var segmentControl: KTSegmentedControl!

    var vModel : KTKarwaBusViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = KTKarwaBusViewModel(del:self)
        vModel = viewModel as? KTKarwaBusViewModel
        (viewModel as! KTKarwaBusViewModel).fetchJourneyPlannerRoutes()
        
        self.addMap()
        // Do any additional setup after loading the view.
        
        segmentControl.items = ["str_near".localized(), "str_route".localized()]
        segmentControl.selectedIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func segmentValueChanged(_ sender: KTSegmentedControl) {
        print("sender.selectedIndex", sender.selectedIndex)
//        segmentControl.selectedIndex = sender.selectedIndex == 0 ? 1 : 0
        self.busRouteTableView.reloadData()
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
      sideMenuController?.revealMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destination.
         Pass the selected object to the new view controller.
    }
    */
}

extension KTKarwaBusViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentControl.selectedIndex == 0 {
            let cell : KarwaRouteTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KarwaRouteTableViewCell") as! KarwaRouteTableViewCell
            return cell
        } else  if segmentControl.selectedIndex == 1 {
            let cell : KarwaNearByTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KarwaNearByTableViewCell") as! KarwaNearByTableViewCell
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    
}


class KarwaRouteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberOfBusView: UIView!
    @IBOutlet weak var numberOfBusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var busIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

class KarwaNearByTableViewCell: UITableViewCell {
    
    @IBOutlet weak var availableBusNumberLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var walkLbl: UILabel!
    @IBOutlet weak var busNumberLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
