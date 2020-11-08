//
//  KTAddressPin.swift
//  KarwaRide
//
//  Created by Umer Afzal on 07/11/2020.
//  Copyright © 2020 Karwa. All rights reserved.
//

import UIKit

class KTAddressPin: UIView {

  private static let PIN_IMAGE_NAME = "location_pin_ico"
  
  private lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: KTAddressPin.PIN_IMAGE_NAME)
    return view
  }()
  
  private lazy var label: UILabel = {
    let label = UILabel()
    label.font = UIFont.H7().regular
    label.textColor = UIColor.primary
    label.textAlignment = .center
    return label
  }()
  
  private lazy var indicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    view.startAnimating()
    return view
  }()
  
  public var eta: String? {
    didSet {
      if let eta = eta, !eta.isEmpty {
        label.text = eta
        label.isHidden = false
        indicator.isHidden = true
      } else {
        label.isHidden = true
        indicator.isHidden = false
      }
    }
  }
  
  override init(frame: CGRect) {
    fatalError("init(frame:) has not been implemented")
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    addSubview(imageView)
    addSubview(label)
    addSubview(indicator)
    label.text = eta
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    imageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    
    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    indicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    
    backgroundColor = UIColor.clear
  }
  
  override var intrinsicContentSize: CGSize {
     return CGSize(width: 90, height: 72)
  }

}
