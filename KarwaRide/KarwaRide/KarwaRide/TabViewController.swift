//
//  TabViewController.swift
//  KarwaRide
//
//  Created by Satheesh Speed Mac on 14/05/21.
//  Copyright © 2021 Karwa. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    
    fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor(hexString: "#006170"), NSAttributedStringKey.font : UIFont(name: "MuseoSans-700", size: 14.0)!], for: .normal)
        
        self.tabBar.unselectedItemTintColor = UIColor(hexString: "#65A0AA")
        
        if #available(iOS 15.0, *) {
            tabBar.backgroundImage = #imageLiteral(resourceName: "tabbarbg")
        }
        
        tabBar.selectionIndicatorImage = UIImage(named: "active_tab_bg")!
            .resizableImage(withCapInsets: UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0))
        
        // remove default border
        tabBar.frame.size.width = self.view.frame.width + 3
        tabBar.frame.origin.x = -2
        tabBar.contentMode = .scaleAspectFill
        tabBar.backgroundColor = .white
        
//        tabBar.customShadowRadius = 3
//        tabBar.customShadowOpacity = 1
//        tabBar.customShadowOffset = CGSize(width: 1, height: 0)
//        tabBar.customShadowColor = UIColor.black.withAlphaComponent(0.7)
        
        if xpressRebookSelected {
            self.selectedIndex = 1
        }
        
        tabBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if #available(iOS 13.0, *) {
//            let appearance = UITabBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = .white
//            tabBar.standardAppearance = appearance
//        } else {
//            // Fallback on earlier versions
//        }
//
//
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            tabBar.standardAppearance = appearance
            //tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }

        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font:UIFont(name: "MuseoSans-700", size: 14.0)!]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        
        guard let items = tabBar.items else { return }

        items[0].title = "str_book_karwa".localized()
        items[1].title = "str_xpress".localized()
        items[2].title = "action_settings".localized()
        
        for item in items {
            item.setTitleTextAttributes([NSAttributedString.Key.font:UIFont(name: "MuseoSans-700", size: 12.0)!, NSAttributedString.Key.foregroundColor: UIColor.primary], for: .normal)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let newTabBarHeight = defaultTabBarHeight + 7
        var newFrame = tabBar.frame
        newFrame.size.height = newTabBarHeight
        newFrame.origin.y = view.frame.size.height - newTabBarHeight
        tabBar.frame = newFrame
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationController?.isNavigationBarHidden = true
    }
    
    
    
}

extension TabViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MyTransition(viewControllers: tabBarController.viewControllers)
    }
}

class MyTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let transitionDuration: Double = 0.5

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(transitionDuration)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let fromIndex = getIndex(forViewController: fromVC),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view,
            let toIndex = getIndex(forViewController: toVC)
            else {
                transitionContext.completeTransition(false)
                return
        }

        let frame = transitionContext.initialFrame(for: fromVC)
        var fromFrameEnd = frame
        var toFrameStart = frame
        fromFrameEnd.origin.x = toIndex > fromIndex ? frame.origin.x - frame.width : frame.origin.x + frame.width
        toFrameStart.origin.x = toIndex > fromIndex ? frame.origin.x + frame.width : frame.origin.x - frame.width
        toView.frame = toFrameStart

        DispatchQueue.main.async {
            transitionContext.containerView.addSubview(toView)
            UIView.animate(withDuration: self.transitionDuration, animations: {
                fromView.frame = fromFrameEnd
                toView.frame = frame
            }, completion: {success in
                fromView.removeFromSuperview()
                transitionContext.completeTransition(success)
            })
        }
    }

    func getIndex(forViewController vc: UIViewController) -> Int? {
        guard let vcs = self.viewControllers else { return nil }
        for (index, thisVC) in vcs.enumerated() {
            if thisVC == vc { return index }
        }
        return nil
    }
}


extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0.0, y: -3.0, width: Double(size.width), height: Double(5))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}


class CustomTabBar : UITabBar {
    @IBInspectable var height: CGFloat = 0.0
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        if height > 0.0 {
            sizeThatFits.height = height
        }
        return sizeThatFits
    }
}
