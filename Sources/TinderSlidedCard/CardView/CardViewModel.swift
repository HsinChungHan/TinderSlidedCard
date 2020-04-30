//
//  CardViewModel.swift
//  TinderCard
//
//  Created by Chung Han Hsin on 2020/4/29.
//  Copyright © 2020 Chung Han Hsin. All rights reserved.
//

import UIKit

public class CardViewModel {
  var currentPhotoIndex = 0
  let name: String
  let textAlignment: NSTextAlignment
  let photos: [UIImage]
  private(set) lazy var attributedString = translationStringToNSAttributedString(str: name)
  
  public init(name: String, textAlignment: NSTextAlignment, photos: [UIImage]) {
    self.name = name
    self.textAlignment = textAlignment
    self.photos = photos
  }

  public func getPhotoMoveForwardIndex(currentIndex: Int, countOfPhotos: Int) -> Int {
    return min(currentIndex + 1, countOfPhotos - 1)
  }
  
  public func getPhotoBackLastIndex(currentIndex: Int, countOfPhotos: Int) -> Int {
    return max(currentIndex - 1, 0)
  }
  
}

extension CardViewModel {
  func translationStringToNSAttributedString(str: String) -> NSAttributedString {
    return NSAttributedString(string: str, attributes: [.font : UIFont.systemFont(ofSize: 32, weight: .heavy)])
  }
}
