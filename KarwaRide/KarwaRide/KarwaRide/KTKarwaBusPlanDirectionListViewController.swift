//
//  KTKarwaBusPlanDirectionListViewController.swift
//  KarwaRide
//
//  Created by Apple on 02/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit

class KTKarwaBusPlanDirectionListViewController: KTBaseViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.estimatedRowHeight = 80
        tblView.rowHeight = UITableViewAutomaticDimension
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    func setupViews() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func progressAlongAxis(_ pointOnAxis: CGFloat, _ axisLength: CGFloat) -> CGFloat {
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
        let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
        return CGFloat(positiveMovementOnAxisPercent)
    }

    func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T: Comparable {
        return min(max(value, minimum), maximum)
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        
//        let percentThreshold:CGFloat = 0.3
//        let translation = sender.translation(in: view)
//
//        let newX = ensureRange(value: view.frame.minY + translation.y, minimum: 0, maximum: view.frame.maxY)
//        let progress = progressAlongAxis(newX, view.bounds.height)
//
//        view.frame.origin.y = newX //Move view to new position
//
//        if sender.state == .ended {
//            let velocity = sender.velocity(in: view)
//
//            print("velocity", velocity)
//
//            if velocity.y >= 1300 || progress > percentThreshold {
//
//                self.dismiss(animated: true) //Perform dismiss
//            } else {
//                UIView.animate(withDuration: 0.2, animations: {
//                    self.view.frame.origin.y = 130 // Revert animation
//                })
//            }
//        }
        
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        let dragVelocity = sender.velocity(in: self.view)
        print("dragVelocity", dragVelocity)
        
        if sender.state == .ended {
            
            if  UIScreen.main.bounds.height/2 < view.frame.origin.y {
                self.dismiss(animated: true, completion: nil)
            }
            if dragVelocity.y >= 1300 {
                // Velocity fast enough to dismiss the uiview
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension KTKarwaBusPlanDirectionListViewController {
    
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
