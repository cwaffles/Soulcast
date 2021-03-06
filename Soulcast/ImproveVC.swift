//
//  FeedbackVC.swift
//  Soulcast
//
//  Created by June Kim on 2016-09-16.
//  Copyright © 2016 Soulcast-team. All rights reserved.
//

import Foundation
import UIKit

protocol ImproveVCDelegate: class {
  func didFinishGettingImprove()
}

class ImproveVC: UIViewController {
  
  weak var delegate:ImproveVCDelegate?
  var outgoingVC = OutgoingVC()
  
  let descriptionText = "Help us improve Soulcast. \nWe're listening!"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    layoutStuff()
    view.backgroundColor = UIColor.white
  }
  
  func layoutStuff() {
    addDescriptionLabel()
    addOutgoingVC()
  }
  
  func addOutgoingVC() {
    outgoingVC.delegate = self
    outgoingVC.soulType = .Improve
    outgoingVC.maxRecordingDuration = 10
    addChildVC(outgoingVC)
    view.addSubview(outgoingVC.view)
    outgoingVC.didMove(toParentViewController: self)
  }
  
  func addDescriptionLabel() {
    let inset:CGFloat = 30
    let descriptionLabel = UILabel(frame: CGRect(
      x: inset,
      y: inset,
      width: view.bounds.width - 2 * inset,
      height: view.bounds.width * 1.2 ))
    descriptionLabel.text = descriptionText
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textColor = UIColor.darkGray
    descriptionLabel.font = UIFont(name: HelveticaNeue, size: 20)
    view.addSubview(descriptionLabel)
  }
}

extension ImproveVC: OutgoingVCDelegate {
  func outgoingRadius() -> Double {
    return 0;
  }
  func outgoingLongitude() -> Double {
    return 0;
  }
  func outgoingLatitude() -> Double {
    return 0;
  }
  func outgoingDidStart() {
    
  }
  func outgoingDidStop() {
    print("outgoingDidStop")
    dismiss(animated: true) { 
      //
    }
  }
}
