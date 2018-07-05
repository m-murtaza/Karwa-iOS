//
//  KTCoachmarkOneViewController.swift
//  KarwaRide
//
//  Created by Sam Ash on 7/3/18.
//  Copyright © 2018 Karwa. All rights reserved.
//

import UIKit

class KTCoachmarkOneViewController: KTBaseViewController {

    @IBOutlet weak var imageView: KTSpringImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.performSegue(name: "SagueCoachmark2")
        
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        print("-->View Will Appear")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        print("-->View Did Appear")
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        print("-->View Will Disappear")
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        print("-->View Did Disappear")
    }
}
