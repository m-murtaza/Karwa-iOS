//
//  KTKarwaBusPlanDirectionViewController.swift
//  KarwaRide
//
//  Created by Apple on 01/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit

class KTKarwaBusPlanDirectionViewController: KTBaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var topAddressHeaderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.estimatedRowHeight = 80
        tblView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func panView(_ gesture: UIPanGestureRecognizer) {
        // 1
        let translation = gesture.translation(in: view)
        
        // 2
        guard let gestureView = gesture.view else {
            return
        }
        
        print("gestureView.center.y", gestureView.center.y)
        print("translation.y", translation.y)
        // in these two cases, don't translate the image view
//        if (gestureView.center.y < 161 && translation.y < 0) ||
//            (gestureView.center.y > 561 && translation.y > 0) {
//            gesture.setTranslation(.zero, in: view)
//            return
//        }
        
        
        print("self.view.frame.height", self.view.frame.height)
        
        // clamping the translated y
        gestureView.center.y = min(max(gestureView.center.y + translation.y, 550), 900)
        gesture.setTranslation(.zero, in: view)
        
        let percentage = gestureView.frame.origin.y/self.view.frame.size.height;
        
        print("percentage", percentage)
        
        topAddressHeaderView.alpha =  1.0 - percentage //min(max(gestureView.center.y + translation.y, 161), 900)
    }

}

extension KTKarwaBusPlanDirectionViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }
        return UITableViewAutomaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : KTKarwaDirectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTKarwaDirectionTableViewCell") as! KTKarwaDirectionTableViewCell
        cell.selectionStyle = .none
        if indexPath.row == 0 {
            cell.directionStackViewImage1.isHidden = false
            cell.directionStackViewImage2.isHidden = false
            cell.directionStackViewImage3.isHidden = true
            cell.directionStackViewImage4.isHidden = true
            cell.topStackView.isHidden = false
            cell.middleStackView.isHidden = true
            cell.bottomStackView.isHidden = true
        } else {
            cell.directionStackViewImage1.isHidden = true
            cell.directionStackViewImage2.isHidden = false
            cell.directionStackViewImage3.isHidden = false
            cell.directionStackViewImage4.isHidden = false
            cell.topStackView.isHidden = false
            cell.middleStackView.isHidden = false
        }
        return cell
    }
}

class KTKarwaDirectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var directionStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var directionStackViewImage1: UIImageView!
    @IBOutlet weak var directionStackViewImage2: UIImageView!
    @IBOutlet weak var directionStackViewImage3: UIImageView!
    @IBOutlet weak var directionStackViewImage4: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
