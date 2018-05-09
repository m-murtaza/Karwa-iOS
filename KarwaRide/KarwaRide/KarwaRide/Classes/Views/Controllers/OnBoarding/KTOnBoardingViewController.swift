//
//  KTOnBoardingViewController.swift
//  KarwaRide
//
//  Created by Muhammad Usman on 5/8/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

protocol KTOnBoardingViewControllerDelegate {
    func update(index: Int)
}

class KTOnBoardingViewController: UIPageViewController, UIPageViewControllerDataSource,UIPageViewControllerDelegate, UIScrollViewDelegate {

    fileprivate var currentIndex = 0
    fileprivate var lastPosition: CGFloat = 0
    var stepsViewControllers : [KTBaseOnBoardingViewController] = []
    var onBoardingDelegate: KTOnBoardingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateData()
        setViewControllers([stepsViewControllers[0]], direction: .forward, animated: false, completion: nil)
        dataSource = self
        delegate = self
        
        for view in view.subviews {
            if view is UIScrollView {
                (view as! UIScrollView).delegate =  self
                break
            }
        }
    }
    
    func populateData() {
        
         stepsViewControllers  = [getStepOne(),getStepTwo(),getStepThree(),getStepFour(),getStepFive()]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        if completed {
            // Get current index
            let pageContentViewController = self.viewControllers![0]
            currentIndex = pageContentViewController.view.tag
            //print(currentIndex)
            onBoardingDelegate?.update(index: currentIndex+1)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
        } else if (currentIndex == stepsViewControllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (currentIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
        } else if (currentIndex == stepsViewControllers.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width) {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0);
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getStepOne() -> KTOnboardingStep1ViewController {
        let v = storyboard!.instantiateViewController(withIdentifier: "OnBoardingStep1") as! KTOnboardingStep1ViewController
        v.view.tag = 0
        return v
    }

    func getStepTwo() -> KTOnboardingStep2ViewController {
        let v = storyboard!.instantiateViewController(withIdentifier: "OnBoardingStep2") as! KTOnboardingStep2ViewController
        v.view.tag = 1
        return v
    }

    func getStepThree() -> KTOnboardingStep3ViewController {
        let v = storyboard!.instantiateViewController(withIdentifier: "OnBoardingStep3") as! KTOnboardingStep3ViewController
        v.view.tag = 2
        return v
    }
    
    func getStepFour() -> KTOnboardingStep4ViewController {
        let v = storyboard!.instantiateViewController(withIdentifier: "OnBoardingStep4") as! KTOnboardingStep4ViewController
        v.view.tag = 3
        return v
    }
    
    func getStepFive() -> KTOnboardingStep5ViewController {
        let v = storyboard!.instantiateViewController(withIdentifier: "OnBoardingStep5") as! KTOnboardingStep5ViewController
        v.view.tag = 4
        return v
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex > 0 {
            return stepsViewControllers[currentIndex-1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex < stepsViewControllers.count-1 {
            return stepsViewControllers[currentIndex+1]
        }
        return nil
    }
}
