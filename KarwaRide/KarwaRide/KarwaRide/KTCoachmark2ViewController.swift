//
//  KTCoachmark2ViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCoachmarkTwoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        SharedPrefUtil.setSharedPref(SharedPrefUtil.IS_COACHMARKS_SHOWN, "true")
        dismiss(animated: true, completion: nil)
    }

}
