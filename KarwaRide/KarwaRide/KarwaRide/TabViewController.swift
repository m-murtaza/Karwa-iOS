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

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor(hexString: "#006170")], for: .normal)
        
        self.tabBar.unselectedItemTintColor = UIColor(hexString: "#65A0AA")
        
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            self.tabBar.layer.zPosition = -1
        }

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
        
        if bookingSuccessful {
            bookingSuccessful = false
            self.selectedIndex = 1
        } else {
            self.selectedIndex = 0
        }
        
        tabBar.shadowImage = UIImage()
        
        guard let items = tabBar.items else { return }

        items[0].title = "str_book_karwa".localized()
        items[1].title = "metroexpress"//.localized()
        items[2].title = "action_settings".localized()
        
        items[0].image = UIImage(named: "Tabbar1")
        items[1].image = UIImage(named: "kmetroexpress")
        items[2].image = UIImage(named: "settings_ico_idle")
        
        items[0].selectedImage = UIImage(named: "Tabbar1")
        items[1].selectedImage = UIImage(named: "kmetroexpress")
        items[2].selectedImage = UIImage(named: "settings_ico_active")
        
        for item in items {
            var normal: [NSAttributedString.Key: AnyObject] =
            [NSAttributedString.Key.font:UIFont(name: "MuseoSans-500", size: 11.0)!]
            normal[NSAttributedString.Key.foregroundColor] = UIColor(hexString: "#006170")
            item.setTitleTextAttributes(normal, for: .normal)
            
            
        }
        
        var normal: [NSAttributedString.Key: AnyObject] =
        [NSAttributedString.Key.font:UIFont(name: "MuseoSans-900", size: 11.0)!]
        normal[NSAttributedString.Key.foregroundColor] = UIColor(hexString: "#006170")
        items[0].setTitleTextAttributes(normal, for: .normal)
    }
    
    override func viewWillLayoutSubviews() {
        // acess to list of tab bar items
        if let items = self.tabBar.items {
            // in each item we have a view where we find 2 subviews imageview and label
            // in this example i would like to change
            // access to item view
            if let viewTabBar = items[1].value(forKey: "view") as? UIView {
                // access to item subviews : imageview and label
                if viewTabBar.subviews.count == 2 {
                    let label = viewTabBar.subviews[1]as? UILabel
                    label?.frame = CGRect(x: 0, y: 0, width: 100, height: 12)
                    // here is the customization for my label 2 lines
                    label?.numberOfLines = 2
                    label?.textAlignment = .center
                    label!.attributedText = addBoldText(fullString: "str_metroexpress".localized() as NSString, boldPartOfString: "\("str_metro".localized())" as NSString, font:  UIFont(name: "MuseoSans-500", size: 11.0)!, boldFont:  UIFont(name: "MuseoSans-900", size: 11.0)!)
                    // here customisation for image insets top and bottom
                    //                    items[2].imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -5, right: 0)
                }
            }
            
            items[2].imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -3, right: 0)

        }
        
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
//        if #available(iOS 15.0, *) {
//            let appearance = UITabBarAppearance()
//            appearance.configureWithOpaqueBackground()
//            appearance.backgroundColor = .white
//            tabBar.standardAppearance = appearance
//            //tabBar.scrollEdgeAppearance = tabBar.standardAppearance
//        }

        
    
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let newTabBarHeight = defaultTabBarHeight + 7
        var newFrame = tabBar.frame
        if !KTConfiguration.sharedInstance.checkRSEnabled() {
            newFrame.size.height = 0
            newFrame.origin.y = view.frame.size.height - 0
        }
        else {
            newFrame.size.height = newTabBarHeight
            newFrame.origin.y = view.frame.size.height - newTabBarHeight
        }
        tabBar.frame = newFrame
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override var selectedViewController: UIViewController? {
        didSet {

            guard let viewControllers = viewControllers else {
                return
            }

            for viewController in viewControllers {

                if viewController == selectedViewController && !selectedViewController!.isKind(of: KTXpressPickUpViewController.self) {

                    if let items = self.tabBar.items {
                        // in each item we have a view where we find 2 subviews imageview and label
                        // in this example i would like to change
                        // access to item view
                        if let viewTabBar = items[1].value(forKey: "view") as? UIView {
                            // access to item subviews : imageview and label
                            if viewTabBar.subviews.count == 2 {
                                let label = viewTabBar.subviews[1]as? UILabel
                                label?.frame = CGRect(x: 17, y: 35, width: 100, height: 12)
                                // here is the customization for my label 2 lines
                                label?.numberOfLines = 2
                                label?.textAlignment = .center
                                label!.attributedText = addBoldText(fullString: "str_metroexpress".localized() as NSString, boldPartOfString: "\("str_metro".localized())" as NSString, font:  UIFont(name: "MuseoSans-500", size: 11.0)!, boldFont:  UIFont(name: "MuseoSans-900", size: 11.0)!)
                                // here customisation for image insets top and bottom
                                //                    items[2].imageInsets = UIEdgeInsets(top: 8, left: 0, bottom: -5, right: 0)
                            }
                        }
                        
                        items[2].imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -3, right: 0)

                    }

                } else if !(viewController.isKind(of: KTXpressPickUpViewController.self)) {

                    var normal: [NSAttributedString.Key: AnyObject] =
                    [NSAttributedString.Key.font:UIFont(name: "MuseoSans-500", size: 11.0)!]
                    normal[NSAttributedString.Key.foregroundColor] = UIColor(hexString: "#006170")
                    viewController.tabBarItem.setTitleTextAttributes(normal, for: .normal)

                }
            }
        }
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
