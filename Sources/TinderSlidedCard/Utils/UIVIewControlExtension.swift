//
//  File.swift
//  
//
//  Created by Chung Han Hsin on 2020/4/30.
//

import UIKit
extension UIView {
  func removeAllSubViewsFromSuperView() {
    subviews.forEach{ $0.removeFromSuperview() }
  }
}
