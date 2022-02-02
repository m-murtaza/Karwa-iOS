//
//  KTKarwaBusPlanDirectionViewController.swift
//  KarwaRide
//
//  Created by Apple on 01/02/22.
//  Copyright © 2022 Karwa. All rights reserved.
//

import UIKit

class KTKarwaBusPlanDirectionViewController: KTBaseViewController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var topAddressHeaderView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var draggableView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.estimatedRowHeight = 80
        tblView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let busStoryboard = UIStoryboard(name: "BusStoryBoard", bundle: .main)
        let directionController = busStoryboard.instantiateViewController(withIdentifier: "KTKarwaBusPlanDirectionListViewController") as! KTKarwaBusPlanDirectionListViewController
        //KTKarwaBusPlanDirectionListViewController()
        directionController.modalPresentationStyle = .custom
        directionController.transitioningDelegate = self
        self.present(directionController, animated: true, completion: nil)
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
//        // 1
//        let translation = gesture.translation(in: view)
//
//        // 2
//        guard let gestureView = gesture.view else {
//            return
//        }
//
//        print("gestureView.center.y", gestureView.center.y)
//        print("translation.y", translation.y)
//        // in these two cases, don't translate the image view
//        print("self.view.frame.height", self.view.frame.height)
//
//        // clamping the translated y
//        gestureView.center.y = min(max(gestureView.center.y + translation.y, 475), 900)
//        gesture.setTranslation(.zero, in: view)
//
//        let percentage = CGFloat(gestureView.frame.origin.y / (self.view.frame.size.height - 135.0));
//
//        print("percentage", percentage)
//
//        print("draggableView.origin.y", draggableView.frame.origin.y)
//
//        topAddressHeaderView.alpha =  1.0 - percentage //min(max(gestureView.center.y + translation.y, 161), 900)
//
//        print("topAddressHeaderView.alpha", topAddressHeaderView.alpha)
    }

}

extension KTKarwaBusPlanDirectionViewController: UIViewControllerTransitioningDelegate {
    // 2.
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        FilterPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


//extension KTKarwaBusPlanDirectionViewController {
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 100
//        }
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 100
//        }
//        return UITableViewAutomaticDimension
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell : KTKarwaDirectionTableViewCell = tableView.dequeueReusableCell(withIdentifier: "KTKarwaDirectionTableViewCell") as! KTKarwaDirectionTableViewCell
//        cell.selectionStyle = .none
//        if indexPath.row == 0 {
//            cell.directionStackViewImage1.isHidden = false
//            cell.directionStackViewImage2.isHidden = false
//            cell.directionStackViewImage3.isHidden = true
//            cell.directionStackViewImage4.isHidden = true
//            cell.topStackView.isHidden = false
//            cell.middleStackView.isHidden = true
//            cell.bottomStackView.isHidden = true
//        } else {
//            cell.directionStackViewImage1.isHidden = true
//            cell.directionStackViewImage2.isHidden = false
//            cell.directionStackViewImage3.isHidden = false
//            cell.directionStackViewImage4.isHidden = false
//            cell.topStackView.isHidden = false
//            cell.middleStackView.isHidden = false
//        }
//        return cell
//    }
//}

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


class FilterPresentationController: UIPresentationController {
  // MARK: Properties
  
  let blurEffectView: UIVisualEffectView!
  var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
  
  // 1.
  override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
      let blurEffect = UIBlurEffect(style: .extraLight)
      blurEffectView = UIVisualEffectView(effect: blurEffect)
      super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
      tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.blurEffectView.isUserInteractionEnabled = true
      self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
  }
  
  // 2.
  override var frameOfPresentedViewInContainerView: CGRect {
      CGRect(origin: CGPoint(x: 0, y: 130),
             size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height * 0.8))
  }

  // 3.
  override func presentationTransitionWillBegin() {
      self.blurEffectView.alpha = 0
      self.containerView?.addSubview(blurEffectView)
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.alpha = 0.7
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
  }
  
  // 4.
  override func dismissalTransitionWillBegin() {
      self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.alpha = 0
      }, completion: { (UIViewControllerTransitionCoordinatorContext) in
          self.blurEffectView.removeFromSuperview()
      })
  }
  
  // 5.
  override func containerViewWillLayoutSubviews() {
      super.containerViewWillLayoutSubviews()
  }

  // 6.
  override func containerViewDidLayoutSubviews() {
      super.containerViewDidLayoutSubviews()
      presentedView?.frame = frameOfPresentedViewInContainerView
      blurEffectView.frame = containerView!.bounds
  }

  // 7.
  @objc func dismissController(){
      self.presentedViewController.dismiss(animated: true, completion: nil)
  }
}
